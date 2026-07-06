import request from 'supertest';
import app from '../../app';
import { UserModel } from '../../models/user.model';

describe('Auth Integration Tests', () => {
  let userToken: string;

  const testUser = {
    name: 'Test',
    email: 'test@yarncraft.com',
    password: 'Password123!',
    confirmPassword: 'Password123!',
  };

  beforeAll(async () => {
    await UserModel.deleteMany({ email: testUser.email });
  });

  afterAll(async () => {
    await UserModel.deleteMany({
      email: { $in: [testUser.email, 'mismatch@yarncraft.com'] },
    });
  });

  // ── REGISTER ─────────────────────────────────────────────────────────────────
  describe('POST /api/auth/register', () => {
    test('1. Should register a new user', async () => {
      const res = await request(app).post('/api/auth/register').send(testUser);
      expect(res.status).toBe(201);
      expect(res.body).toHaveProperty('success', true);
    });

    test('2. Should not register with a duplicate email', async () => {
      const res = await request(app).post('/api/auth/register').send(testUser);
      expect(res.status).toBe(409);
      expect(res.body).toHaveProperty('success', false);
    });

    test('3. Should fail with a short password', async () => {
      const res = await request(app).post('/api/auth/register').send({
        name: 'Shorty',
        email: 'short@yarncraft.com',
        password: '123',
        confirmPassword: '123',
      });
      expect(res.status).toBe(400);
    });

    test('4. Should fail with no body', async () => {
      const res = await request(app).post('/api/auth/register').send({});
      expect(res.status).toBe(400);
    });

    test('5. Should fail when confirmPassword does not match', async () => {
      const res = await request(app).post('/api/auth/register').send({
        name: 'Mismatch',
        email: 'mismatch@yarncraft.com',
        password: 'Password123!',
        confirmPassword: 'Password456!',
      });
      expect(res.status).toBe(400);
    });

    test('6. Should fail with a missing email', async () => {
      const res = await request(app).post('/api/auth/register').send({
        name: 'NoEmail',
        password: 'Password123!',
        confirmPassword: 'Password123!',
      });
      expect(res.status).toBe(400);
    });
  });

  // ── LOGIN ────────────────────────────────────────────────────────────────────
  describe('POST /api/auth/login', () => {
    test('7. Should login an existing user', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: testUser.email, password: testUser.password });
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('success', true);
      expect(res.body).toHaveProperty('token');
      userToken = res.body.token;
    });

    test('8. Should not login with an incorrect password', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: testUser.email, password: 'WrongPassword!' });
      expect(res.status).toBe(401);
    });

    test('9. Should fail login with an empty body', async () => {
      const res = await request(app).post('/api/auth/login').send({});
      expect(res.status).toBe(400);
    });

    test('10. Should fail login with a missing password', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: testUser.email });
      expect(res.status).toBe(400);
    });

    test('11. Should fail login with an invalid email format', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: 'notanemail', password: 'Password123!' });
      expect(res.status).toBe(400);
    });

    test('12. Should fail login with a non-existent email', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: 'ghost@yarncraft.com', password: 'Password123!' });
      expect(res.status).toBe(404);
    });
  });

  // ── GET PROFILE (/api/auth/me) ────────────────────────────────────────────────
  describe('GET /api/auth/me', () => {
    test('13. Should get the current user profile', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${userToken}`);
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('email', testUser.email);
      expect(res.body.data).toHaveProperty('name');
    });

    test('14. Should fail to get profile without auth', async () => {
      const res = await request(app).get('/api/auth/me');
      expect(res.status).toBe(401);
    });

    test('15. Should fail to get profile with an invalid token', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', 'Bearer invalidtoken');
      expect(res.status).toBe(401);
    });
  });

  // ── UPDATE PROFILE (/api/auth/me/update) ──────────────────────────────────────
  describe('PATCH /api/auth/me/update', () => {
    test('16. Should update the user name', async () => {
      const res = await request(app)
        .patch('/api/auth/me/update')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ name: 'Updated Name' });
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
    });

    test('17. Should fail to update without auth', async () => {
      const res = await request(app)
        .patch('/api/auth/me/update')
        .send({ name: 'Hacker' });
      expect(res.status).toBe(401);
    });

    test('18. Should fail to update with an invalid email format', async () => {
      const res = await request(app)
        .patch('/api/auth/me/update')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ email: 'bademail' });
      expect(res.status).toBe(400);
    });

    test('19. Should reflect the updated name in the profile', async () => {
      await request(app)
        .patch('/api/auth/me/update')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ name: 'FinalName' });

      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${userToken}`);
      expect(res.status).toBe(200);
      expect(res.body.data.name).toBe('FinalName');
    });
  });

  // ── FORGOT PASSWORD (/api/auth/forgot-password) ───────────────────────────────
  describe('POST /api/auth/forgot-password', () => {
    test('20. Should return success for a registered account', async () => {
      const res = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email_or_phone: testUser.email });
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
    });

    test('21. Should return success for an unknown account (no enumeration)', async () => {
      const res = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email_or_phone: 'ghost@yarncraft.com' });
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
    });

    test('22. Should fail when email_or_phone is missing', async () => {
      const res = await request(app).post('/api/auth/forgot-password').send({});
      expect(res.status).toBe(400);
    });
  });

  // ── RESET PASSWORD (/api/auth/reset-password) ─────────────────────────────────
  describe('POST /api/auth/reset-password', () => {
    test('23. Should fail with an invalid/expired token', async () => {
      const res = await request(app).post('/api/auth/reset-password').send({
        token: '000000',
        new_password: 'NewPassword123!',
        confirm_password: 'NewPassword123!',
      });
      expect(res.status).toBe(400);
    });

    test('24. Should fail when passwords do not match', async () => {
      const res = await request(app).post('/api/auth/reset-password').send({
        token: '000000',
        new_password: 'NewPassword123!',
        confirm_password: 'Different123!',
      });
      expect(res.status).toBe(400);
    });
  });
});
