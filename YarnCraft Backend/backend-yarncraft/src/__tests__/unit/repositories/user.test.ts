import { UserRepository } from '../../../repositories/user.repository';
import { UserModel } from '../../../models/user.model';

describe('User Repository Unit Tests', () => {
  let userRepository: UserRepository;

  const testEmail = 'repo-unit@yarncraft.com';

  beforeAll(() => {
    userRepository = new UserRepository();
  });

  afterEach(async () => {
    await UserModel.deleteMany({ email: testEmail });
  });

  test('1. Should create a new user', async () => {
    const userData = {
      name: 'RepoTest',
      email: testEmail,
      password: 'Password123!',
    };

    const newUser = await userRepository.createUser(userData);
    expect(newUser).toBeDefined();
    expect(newUser.email).toBe(testEmail);
  });

  test('2. Should fetch a user by email (with password selected)', async () => {
    await userRepository.createUser({
      name: 'RepoTest',
      email: testEmail,
      password: 'Password123!',
    });

    const found = await userRepository.getUserByEmail(testEmail);
    expect(found).not.toBeNull();
    expect(found?.email).toBe(testEmail);
    expect(found?.password).toBeDefined();
  });

  test('3. Should update a user', async () => {
    const created = await userRepository.createUser({
      name: 'RepoTest',
      email: testEmail,
      password: 'Password123!',
    });

    const updated = await userRepository.updateUser(created._id.toString(), { name: 'Renamed' });
    expect(updated?.name).toBe('Renamed');
  });

  test('4. Should delete a user', async () => {
    const created = await userRepository.createUser({
      name: 'RepoTest',
      email: testEmail,
      password: 'Password123!',
    });

    const deleted = await userRepository.deleteUser(created._id.toString());
    expect(deleted).toBe(true);

    const found = await userRepository.getUserById(created._id.toString());
    expect(found).toBeNull();
  });

  test('5. Should paginate users via getAllUsers', async () => {
    await userRepository.createUser({
      name: 'RepoTest',
      email: testEmail,
      password: 'Password123!',
    });

    const { users, total } = await userRepository.getAllUsers(1, 10);
    expect(Array.isArray(users)).toBe(true);
    expect(typeof total).toBe('number');
  });
});
