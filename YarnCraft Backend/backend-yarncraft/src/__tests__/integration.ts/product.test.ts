import request from 'supertest';
import app from '../../app';
import { ProductModel } from '../../models/product.model';

const BASE = '/api/products';

describe('Product Integration Tests', () => {
  let createdProductId: string;

  const validProduct = {
    name: 'Merino Wool Yarn',
    description: 'Soft 100% merino wool, fingering weight',
    price: 899,
    quantity: 50,
  };

  beforeAll(async () => {
    await ProductModel.deleteMany({ name: validProduct.name });
  });

  afterAll(async () => {
    await ProductModel.deleteMany({ name: { $in: [validProduct.name, 'Updated Yarn'] } });
  });

  // ── CREATE ───────────────────────────────────────────────────────────────────
  describe('POST /api/products', () => {
    test('1. Should create a product', async () => {
      const res = await request(app).post(BASE).send(validProduct);
      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('_id');
      createdProductId = res.body.data._id;
    });

    test('2. Should fail with a missing name', async () => {
      const res = await request(app).post(BASE).send({ price: 100, quantity: 10 });
      expect(res.status).toBe(400);
    });

    test('3. Should fail with a negative price', async () => {
      const res = await request(app)
        .post(BASE)
        .send({ name: 'Bad Yarn', price: -5, quantity: 10 });
      expect(res.status).toBe(400);
    });

    test('4. Should fail with a non-integer quantity', async () => {
      const res = await request(app)
        .post(BASE)
        .send({ name: 'Bad Yarn', price: 5, quantity: 2.5 });
      expect(res.status).toBe(400);
    });

    test('5. Should fail with an empty body', async () => {
      const res = await request(app).post(BASE).send({});
      expect(res.status).toBe(400);
    });
  });

  // ── READ ─────────────────────────────────────────────────────────────────────
  describe('GET /api/products', () => {
    test('6. Should list all products', async () => {
      const res = await request(app).get(BASE);
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    test('7. Should get a product by valid ID', async () => {
      const res = await request(app).get(`${BASE}/${createdProductId}`);
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('_id', createdProductId);
    });

    test('8. Should return 404 for a non-existing valid ObjectId', async () => {
      const res = await request(app).get(`${BASE}/64f000000000000000000000`);
      expect(res.status).toBe(404);
    });

    test('9. Should error for an invalid ID format', async () => {
      const res = await request(app).get(`${BASE}/invalid-id`);
      expect(res.status).toBe(500);
    });
  });

  // ── UPDATE ─────────────────────────────────────────────────────────────────────
  describe('PUT /api/products/:id', () => {
    test('10. Should update a product', async () => {
      const res = await request(app)
        .put(`${BASE}/${createdProductId}`)
        .send({ name: 'Updated Yarn', price: 999 });
      expect(res.status).toBe(200);
      expect(res.body.data.name).toBe('Updated Yarn');
    });

    test('11. Should fail with an invalid price on update', async () => {
      const res = await request(app)
        .put(`${BASE}/${createdProductId}`)
        .send({ price: -100 });
      expect(res.status).toBe(400);
    });

    test('12. Should return 404 when updating a non-existing product', async () => {
      const res = await request(app)
        .put(`${BASE}/64f000000000000000000000`)
        .send({ name: 'Ghost' });
      expect(res.status).toBe(404);
    });
  });

  // ── DELETE ─────────────────────────────────────────────────────────────────────
  describe('DELETE /api/products/:id', () => {
    test('13. Should delete a product', async () => {
      const res = await request(app).delete(`${BASE}/${createdProductId}`);
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
    });

    test('14. Should return 404 when deleting an already deleted product', async () => {
      const res = await request(app).delete(`${BASE}/${createdProductId}`);
      expect(res.status).toBe(404);
    });
  });
});
