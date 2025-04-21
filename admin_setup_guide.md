# Afrilingo Admin Setup Guide

## Creating an Admin User

To create an admin user for Afrilingo, you can use the following JSON template with Postman or any API client:

```json
{
  "firstName": "Admin",
  "lastName": "User",
  "email": "admin@afrilingo.com",
  "password": "Admin@123",
  "role": "ADMIN"
}
```

Send this JSON to the following endpoint:
```
POST http://localhost:8080/api/v1/auth/register
```

Alternatively, you can use the admin creation functionality in the AuthService class:

```dart
final authService = AuthService();
final result = await authService.createAdmin(
  "Admin",
  "User",
  "admin@afrilingo.com",
  "Admin@123"
);
```

## Fixing Chatbot API Issues

### Issue 1: API Key Not Being Detected

The chatbot feature requires a valid DeepSeek API key. There are two ways to provide this key:

1. **Environment Variable**: Add the API key to your `.env` file:
   ```
   OPENROUTER_API_KEY=your-api-key-here
   ```

2. **Manual Entry**: When prompted in the app, enter your DeepSeek API key that starts with `sk-`.

The default API key has been configured in the DeepSeekService, but for security and reliability, it's recommended to use your own API key.

### Issue 2: API Connection

Ensure your backend server is running and accessible at `http://10.0.2.2:8080` (for Android emulator) or adjust the base URL in the service files if needed.

## Admin Features

As an admin, you now have access to:

1. **Admin Dashboard**: Accessible from the user dashboard when logged in as an admin
2. **Language Management**: Add, edit, and delete languages
3. **Course Management**: Add, edit, and delete courses for each language

All content is dynamically managed through the admin interface, allowing you to customize the learning experience for your users.

## Troubleshooting

If you encounter issues:

1. Check that your backend server is running
2. Verify your API key format (should start with `sk-`)
3. Check network connectivity between the app and backend
4. Review server logs for any API errors