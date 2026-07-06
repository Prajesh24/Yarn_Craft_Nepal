import request from 'supertest';
import app from '../../app';
import { UserModel } from '../../models/user.model';
import { CartModel } from '../../models/cart.model';

const BASE = '/api/cart';

describe('Cart Integration Tests', () => {
  let userToken: string;
  let userId: string;

  const cartUser = {
    name: 'CartUser',
    email: 'cart@yarncraft.com',
    password: 'Password123!',
    confirmPassword: 'Password123!',
  };

  beforeAll(async () => {
    await UserModel.deleteMany({ email: cartUser.email });

    await request(app).post('/api/auth/register').send(cartUser);
    const login = await request(app)
      .post('/api/auth/login')
      .send({ email: cartUser.email, password: cartUser.password });
    userToken = login.body.token;
    userId = login.body.data._id;
  });

  afterAll(async () => {
    await UserModel.deleteMany({ email: cartUser.email });
    await CartModel.deleteMany({ userId });
  });

  // ── GET CART ───────────────────────────────────────────────────────────────
  describe('GET /api/cart', () => {
    test('1. Should return an (empty) cart for an authed user', async () => {
      const res = await request(app).get(BASE).set('Authorization', `Bearer ${userToken}`);
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('items');
      expect(Array.isArray(res.body.data.items)).toBe(true);
    });

    test('2. Should fail without an auth token', async () => {
      const res = await request(app).get(BASE);
      expect(res.status).toBe(401);
    });

    test('3. Should fail with an invalid token', async () => {
      const res = await request(app).get(BASE).set('Authorization', 'Bearer invalidtoken');
      expect(res.status).toBe(401);
    });
  });

  // ── UPDATE CART ──────────────────────────────────────────────────────────────
  describe('PUT /api/cart', () => {
    test('4. Should add items to the cart', async () => {
      const res = await request(app)
        .put(BASE)
        .set('Authorization', `Bearer ${userToken}`)
        .send({ items: [{ productId: 'prod-1', quantity: 2 }] });
      expect(res.status).toBe(200);
      expect(res.body.data.items).toHaveLength(1);
      expect(res.body.data.items[0].quantity).toBe(2);
    });

    test('5. Should update an existing cart (upsert)', async () => {
      const res = await request(app)
        .put(BASE)
        .set('Authorization', `Bearer ${userToken}`)
        .send({ items: [{ productId: 'prod-1', quantity: 5 }, { productId: 'prod-2', quantity: 1 }] });
      expect(res.status).toBe(200);
      expect(res.body.data.items).toHaveLength(2);
    });

    test('6. Should fail with an invalid item (quantity < 1)', async () => {
      const res = await request(app)
        .put(BASE)
        .set('Authorization', `Bearer ${userToken}`)
        .send({ items: [{ productId: 'prod-1', quantity: 0 }] });
      expect(res.status).toBe(400);
    });

    test('7. Should fail to update without an auth token', async () => {
      const res = await request(app)
        .put(BASE)
        .send({ items: [{ productId: 'prod-1', quantity: 2 }] });
      expect(res.status).toBe(401);
    });

    test('8. Should clear the cart with an empty items array', async () => {
      const res = await request(app)
        .put(BASE)
        .set('Authorization', `Bearer ${userToken}`)
        .send({ items: [] });
      expect(res.status).toBe(200);
      expect(res.body.data.items).toHaveLength(0);
    });
  });
});
