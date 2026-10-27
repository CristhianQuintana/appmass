/**
 * Crea usuarios de prueba y les asigna rol con sb_secret_ / service_role.
 */
const url = (process.env.SUPABASE_URL || '').replace(/\/$/, '');
const secret = process.env.SUPABASE_SECRET || '';

if (!url || !secret) {
  console.error('Faltan SUPABASE_URL o SUPABASE_SECRET.');
  process.exit(1);
}

const users = [
  {
    email: 'marco.admin@mass.local',
    password: 'Demostracion1',
    fullName: 'Marco Salazar',
    role: 'administrator',
  },
  {
    email: 'ana.operadora@mass.local',
    password: 'Demostracion1',
    fullName: 'Ana Quispe',
    role: 'operator',
  },
  {
    email: 'luis.reparto@mass.local',
    password: 'Demostracion1',
    fullName: 'Luis Huamán',
    role: 'courier',
  },
  {
    email: 'rosa.cliente@mass.local',
    password: 'Demostracion1',
    fullName: 'Rosa Mendoza',
    role: 'customer',
  },
];

const headers = {
  apikey: secret,
  Authorization: `Bearer ${secret}`,
  'Content-Type': 'application/json',
  'User-Agent': 'app-mass-provision/1.0',
};

async function listUsers() {
  const response = await fetch(`${url}/auth/v1/admin/users?page=1&per_page=200`, {
    headers,
  });
  if (!response.ok) {
    throw new Error(`list users ${response.status}: ${await response.text()}`);
  }
  const body = await response.json();
  return body.users || [];
}

async function createUser(user) {
  const response = await fetch(`${url}/auth/v1/admin/users`, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      email: user.email,
      password: user.password,
      email_confirm: true,
      user_metadata: { full_name: user.fullName },
    }),
  });
  if (!response.ok) {
    throw new Error(`create ${user.email} ${response.status}: ${await response.text()}`);
  }
  return response.json();
}

async function provision(userId, fullName, role) {
  const response = await fetch(`${url}/rest/v1/rpc/provision_staff_profile`, {
    method: 'POST',
    headers: {
      ...headers,
      Prefer: 'return=minimal',
    },
    body: JSON.stringify({
      target_user_id: userId,
      target_full_name: fullName,
      target_role: role,
      target_active: true,
    }),
  });
  if (!response.ok) {
    throw new Error(`provision ${userId} ${response.status}: ${await response.text()}`);
  }
}

async function main() {
  const existing = await listUsers();
  for (const user of users) {
    let row = existing.find((item) => item.email === user.email);
    if (!row) {
      row = await createUser(user);
      console.log(`creado ${user.email} -> ${row.id}`);
    } else {
      console.log(`existe ${user.email} -> ${row.id}`);
    }
    await provision(row.id, user.fullName, user.role);
    console.log(`rol ${user.role} activo`);
  }
  console.log('Listo. Contraseña de prueba: Demostracion1');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
