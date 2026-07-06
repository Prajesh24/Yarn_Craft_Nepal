import { connectDatabase } from '../database/mongodb';
import mongoose from 'mongoose';

// Connect once before the whole test run
beforeAll(async () => {
  await connectDatabase();
});

// Close the connection after all tests complete
afterAll(async () => {
  await mongoose.connection.close();
});
