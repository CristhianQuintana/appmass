from __future__ import annotations

import argparse
import csv
import re
import time
from pathlib import Path

import requests

INPUT_CSV = Path("products.csv")
OUTPUT_REVIEW_CSV = Path("imagenes_candidatas_mass.csv")
OUTPUT_SQL = Path("actualizar_imagenes_mass.sql")

API_URL = "https://world.openfoodfacts.org/cgi/search.pl"
USER_AGENT = "AppMASS-ImageCatalogReview/1.0 (catalog image URL audit)"


def normalize(value: str) -> str:
    value = (value or "").lower().strip()
    value = re.sub(r"[^a-z0-9áéíóúüñ ]+", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value


def search_candidate(session: requests.Session, name: str, category: str) -> dict:
    terms = " ".join(part for part in [name, category] if part)
    params = {
        "search_terms": terms,
        "search_simple": 1,
        "action": "process",
        "json": 1,
        "page_size": 10,
        "fields": "product_name,brands,quantity,code,image_front_url,image_url,url",
    }
    response = session.get(API_URL, params=params, timeout=25)
    response.raise_for_status()
    products = response.json().get("products", [])

    wanted = normalize(name)
    best = None
    best_score = -1.0
    wanted_tokens = set(wanted.split())

    for product in products:
        product_name = product.get("product_name") or ""
        image_url = product.get("image_front_url") or product.get("image_url") or ""
        if not product_name or not image_url.startswith("https://"):
            continue

        candidate_tokens = set(normalize(product_name).split())
        union = wanted_tokens | candidate_tokens
        score = len(wanted_tokens & candidate_tokens) / len(union) if union else 0.0

        if normalize(product_name) == wanted:
            score += 1.0
        if score > best_score:
            best_score = score
            best = {
                "candidate_name": product_name,
                "brand": product.get("brands", "") or "",
                "quantity": product.get("quantity", "") or "",
                "barcode": product.get("code", "") or "",
                "image_url": image_url,
                "source_url": product.get("url", "") or "",
                "similarity_score": round(score, 3),
            }

    return best or {
        "candidate_name": "",
        "brand": "",
        "quantity": "",
        "barcode": "",
        "image_url": "",
        "source_url": "",
        "similarity_score": 0,
    }


def sql_quote(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def write_sql(reviewed_rows: list[dict]) -> int:
    approved = [
        row
        for row in reviewed_rows
        if str(row.get("approved", "")).strip().upper() == "YES"
        and str(row.get("image_url", "")).startswith("https://")
    ]

    with OUTPUT_SQL.open("w", encoding="utf-8") as file:
        file.write("-- Revisar antes de ejecutar en Supabase SQL Editor.\n")
        file.write("-- Solo contiene productos aprobados manualmente.\n")
        file.write("BEGIN;\n\n")
        if approved:
            file.write(
                "UPDATE public.products AS p\n"
                "SET image_url = v.image_url, updated_at = timezone('utc', now())\n"
                "FROM (VALUES\n"
            )
            values = [
                f"  ({sql_quote(row['sku'])}, {sql_quote(row['image_url'])})"
                for row in approved
            ]
            file.write(",\n".join(values) + "\n")
            file.write(") AS v(sku, image_url)\nWHERE p.sku = v.sku;\n\n")
        else:
            file.write("-- No hay imágenes aprobadas. No se modificó ninguna fila.\n\n")
        file.write("COMMIT;\n")
    return len(approved)


def propose() -> None:
    if not INPUT_CSV.exists():
        raise SystemExit(
            "No existe products.csv. Exporta desde Supabase las columnas sku,name,category."
        )

    with INPUT_CSV.open("r", encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        required = {"sku", "name", "category"}
        if not reader.fieldnames or not required.issubset(set(reader.fieldnames)):
            raise SystemExit("products.csv debe contener: sku,name,category")
        rows = list(reader)

    session = requests.Session()
    session.headers.update({"User-Agent": USER_AGENT})
    reviewed_rows: list[dict] = []

    for index, row in enumerate(rows, start=1):
        sku = (row.get("sku") or "").strip()
        name = (row.get("name") or "").strip()
        category = (row.get("category") or "").strip()
        if not sku or not name:
            continue

        try:
            candidate = search_candidate(session, name, category)
        except (requests.RequestException, ValueError) as error:
            candidate = {
                "candidate_name": "",
                "brand": "",
                "quantity": "",
                "barcode": "",
                "image_url": "",
                "source_url": "",
                "similarity_score": 0,
            }
            print(f"Aviso: no se pudo consultar {sku}: {error}")

        reviewed_rows.append(
            {
                "sku": sku,
                "catalog_name": name,
                "category": category,
                **candidate,
                "approved": "NO",
            }
        )
        print(
            f"[{index}/{len(rows)}] {sku}: "
            f"{candidate['candidate_name'] or 'sin resultado'} "
            f"(score={candidate['similarity_score']})"
        )
        time.sleep(1.0)

    columns = [
        "sku",
        "catalog_name",
        "category",
        "candidate_name",
        "brand",
        "quantity",
        "barcode",
        "image_url",
        "source_url",
        "similarity_score",
        "approved",
    ]
    with OUTPUT_REVIEW_CSV.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=columns)
        writer.writeheader()
        writer.writerows(reviewed_rows)

    count = write_sql(reviewed_rows)
    print(f"\nCandidatos: {OUTPUT_REVIEW_CSV}")
    print(f"SQL: {OUTPUT_SQL} ({count} aprobados)")


def from_review(min_score: float | None = None) -> None:
    if not OUTPUT_REVIEW_CSV.exists():
        raise SystemExit(f"No existe {OUTPUT_REVIEW_CSV}")

    with OUTPUT_REVIEW_CSV.open("r", encoding="utf-8-sig", newline="") as file:
        rows = list(csv.DictReader(file))

    if min_score is not None:
        for row in rows:
            try:
                score = float(row.get("similarity_score") or 0)
            except ValueError:
                score = 0.0
            image = (row.get("image_url") or "").strip()
            if score >= min_score and image.startswith("https://"):
                row["approved"] = "YES"

        columns = list(rows[0].keys()) if rows else []
        with OUTPUT_REVIEW_CSV.open("w", encoding="utf-8-sig", newline="") as file:
            writer = csv.DictWriter(file, fieldnames=columns)
            writer.writeheader()
            writer.writerows(rows)

    count = write_sql(rows)
    print(f"SQL: {OUTPUT_SQL} ({count} aprobados)")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--from-review",
        action="store_true",
        help="Genera SQL desde imagenes_candidatas_mass.csv sin volver a consultar la API",
    )
    parser.add_argument(
        "--auto-approve-min-score",
        type=float,
        default=None,
        help="Marca YES las filas con score >= umbral e image_url https (solo con --from-review)",
    )
    args = parser.parse_args()
    if args.from_review:
        from_review(args.auto_approve_min_score)
    else:
        propose()


if __name__ == "__main__":
    main()
