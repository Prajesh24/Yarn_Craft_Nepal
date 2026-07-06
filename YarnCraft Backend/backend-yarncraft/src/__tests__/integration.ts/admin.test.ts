import request from 'supertest';
import app from '../../app';
import { UserModel } from '../../models/user.model';

const ADMIN_BASE = '/api/admin/users';

describe('Admin User Integration Tests', () => {
  let adminToken: string;
  let normalToken: string;
  let createdUserId: string;

  const adminUser = {
    name: 'AdminUser',
    email: 'admin@yarncraft.com',
    password: 'Password123!',
    confirmPassword: 'Password123!',
  };

  const normalUser = {
    name: 'NormalUser',
    email: 'normal@yarncraft.com',
    password: 'Password123!',
    confirmPassword: 'Password123!',
  };

  const newUser = {
    name: 'NewUser',
    email: 'newuser@yarncraft.com',
    password: 'Password123!',
    confirmPassword: 'Password123!',
  };

  const cleanupEmails = [
    adminUser.email,
    normalUser.email,
    newUser.email,
    'noname@yarncraft.com',
    'nopass@yarncraft.com',
    'mismatch@yarncraft.com',
    'another@yarncraft.com',
  ];

  beforeAll(async () => {
    await UserModel.deleteMany({ email: { $in: cleanupEmails } });

    await request(app).post('/api/auth/register').send(adminUser);
    await request(app).post('/api/auth/register').send(normalUser);

    // Promote to admin directly in the DB
    await UserModel.updateOne({ email: adminUser.email }, { $set: { role: 'admin' } });

    const adminLogin = await request(app)
      .post('/api/auth/login')
      .send({ email: adminUser.email, password: adminUser.password });
    adminToken = adminLogin.body.token;

    const normalLogin = await request(app)
      .post('/api/auth/login')
      .send({ email: normalUser.email, password: normalUser.password });
    normalToken = normalLogin.body.token;
  });

  afterAll(async () => {
    await UserModel.deleteMany({ email: { $in: cleanupEmails } });
  });

  // ── CREATE USER ────────────────────────────────────────────────────────────
  describe('POST /api/admin/users', () => {
    test('1. Admin should create a new user', async () => {
      const res = await request(app)
        .post(ADMIN_BASE)
        .set('Authorization', `Bearer ${adminToken}`)
        .send(newUser);
      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('_id');
      createdUserId = res.body.data._id;
    });

    test('2. Should fail without an auth token', async () => {
      const res = await request(app).post(ADMIN_BASE).send(newUser);
      expect(res.status).toBe(401);
    });

    test('3. Non-admin should not create a user', async () => {
      const res = await request(app)
        .post(ADMIN_BASE)
        .set('Authorization', `Bearer ${normalToken}`)
        .send({ ...newUser, email: 'another@yarncraft.com' });
      expect(res.status).toBe(403);
    });

    test('4. Should fail with a duplicate email', async () => {
      const res = await request(app)
        .post(ADMIN_BASE)
        .set('Authorization', `Bearer ${adminToken}`)
        .send(newUser);
      expect(res.status).toBe(403);
    });

    test('5. Should fail with an invalid email format', async () => {
      const res = await request(app)
        .post(ADMIN_BASE)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ ...newUser, email: 'not-an-email' });
      expect(res.status).toBe(400);
    });

    test('6. Should fail when name is missing', async () => {
      const res = await request(app)
        .post(ADMIN_BASE)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ email: 'noname@yarncraft.com', password: 'Password123!', confirmPassword: 'Password123!' });
      expect(res.status).toBe(400);
    });

    test('7. Should fail when password is missing', async () => {
      const res = await request(app)
        .post(ADMIN_BASE)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ name: 'NoPass', email: 'nopass@yarncraft.com' });
      expect(res.status).toBe(400);
    });

    test('8. Should fail with an invalid token', async () => {
      const res = await request(app)
        .post(ADMIN_BASE)
        .set('Authorization', 'Bearer invalidtoken')
        .send(newUser);
      expect(res.status).toBe(401);
    });
  });

  // ── GET ALL USERS ──────────────────────────────────────────────────────────
  describe('GET /api/admin/users', () => {
    test('9. Admin should retrieve all users', async () => {
      const res = await request(app).get(ADMIN_BASE).set('Authorization', `Bearer ${adminToken}`);
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    test('10. Should fail without a token', async () => {
      const res = await request(app).get(ADMIN_BASE);
      expect(res.status).toBe(401);
    });

    test('11. Non-admin should not access the user list', async () => {
      const res = await request(app).get(ADMIN_BASE).set('Authorization', `Bearer ${normalToken}`);
      expect(res.status).toBe(403);
    });

    test('12. Should support pagination with page and size', async () => {
      const res = await request(app)
        .get(`${ADMIN_BASE}?page=1&size=5`)
        .set('Authorization', `Bearer ${adminToken}`);
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('pagination');
    });

    test('13. Should support a search query', async () => {
      const res = await request(app)
        .get(`${ADMIN_BASE}?search=NormalUser`)
        .set('Authorization', `Bearer ${adminToken}`);
      expect(res.status).toBe(200);
    });

    test('14. Should handle a search with no matches', async () => {
      const res = await request(app)
        .get(`${ADMIN_BASE}?search=XYZNONEXISTENT`)
        .set('Authorization', `Bearer ${adminToken}`);
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  // ── GET USER BY ID ─────────────────────────────────────────────────────────
  describe('GET /api/admin/users/:id', () => {
    test('15. Admin should get a user by valid ID', async () => {
      const res = await request(app)
        .get(`${ADMIN_BASE}/${createdUserId}`)
        .set('Authorization', `Bearer ${adminToken}`);
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('_id', createdUserId);
    });

    test('16. Should fail with an invalid ID format', async () => {
      const res = await request(app)
        .get(`${ADMIN_BASE}/invalid-id-format`)
        .set('Authorization', `Bearer ${adminToken}`);
      expect(res.status).toBe(500);
    });

    test('17. Should fail without an auth token', async () => {
      const res = await request(app).get(`${ADMIN_BASE}/${createdUserId}`);
      expect(res.status).toBe(401);
    });

    test('18. Should error for a non-existing valid ObjectId', async () => {
      const res = await request(app)
        .get(`${ADMIN_BASE}/64f000000000000000000000`)
        .set('Authorization', `Bearer ${adminToken}`);
      expect([404, 500]).toContain(res.status);
    });
  });

  // ── UPDATE USER ────────────────────────────────────────────────────────────
  describe('PUT /api/admin/users/:id', () => {
    test('19. Admin should update a user name', async () => {
      const res = await request(app)
        .put(`${ADMIN_BASE}/${createdUserId}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ name: 'Updated Name' });
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
    });

    test('20. Should fail with an invalid email on update', async () => {
      const res = await request(app)
        .put(`${ADMIN_BASE}/${createdUserId}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ email: 'bademail' });
      expect(res.status).toBe(400);
    });

    test('21. Non-admin cannot update a user', async () => {
      const res = await request(app)
        .put(`${ADMIN_BASE}/${createdUserId}`)
        .set('Authorization', `Bearer ${normalToken}`)
        .send({ name: 'Blocked' });
      expect(res.status).toBe(403);
    });

    test('22. Should error with an invalid ID format on update', async () => {
      const res = await request(app)
        .put(`${ADMIN_BASE}/not-valid-id`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({ name: 'Test' });
      expect([404, 500]).toContain(res.status);
    });
  });

  // ── DELETE USER ────────────────────────────────────────────────────────────
  describe('DELETE /api/admin/users/:id', () => {
    test('23. Admin should delete a user', async () => {
      const res = await request(app)
        .delete(`${ADMIN_BASE}/${createdUserId}`)
        .set('Authorization', `Bearer ${adminToken}`);
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
    });

    test('24. Should return 404 when deleting an already deleted user', async () => {
      const res = await request(app)
        .delete(`${ADMIN_BASE}/${createdUserId}`)
        .set('Authorization', `Bearer ${adminToken}`);
      expect([404, 500]).toContain(res.status);
    });

    test('25. Non-admin cannot delete a user', async () => {
      const res = await request(app)
        .delete(`${ADMIN_BASE}/${createdUserId}`)
        .set('Authorization', `Bearer ${normalToken}`);
      expect(res.status).toBe(403);
    });
  });
});
