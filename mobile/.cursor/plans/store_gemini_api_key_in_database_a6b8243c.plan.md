---
name: Store Gemini API Key in Database
overview: Move the hardcoded Gemini API key from app_config.dart to a database table, fetch it after login, and update AppConfig to retrieve it from the database with fallback to the hardcoded default.
todos:
  - id: create-db-table
    content: Create app_config table in PostgreSQL database with gemini_api_key entry
    status: completed
  - id: update-app-config
    content: Update AppConfig.getGeminiApiKey() to fetch from database first, then fallback to existing logic
    status: completed
  - id: add-api-endpoint
    content: Add backend API endpoint to fetch gemini_api_key (or include in login response)
    status: completed
  - id: update-auth-service
    content: Update AuthService.login() to fetch and cache API key after successful login
    status: completed
  - id: add-fetch-method
    content: Add fetchGeminiApiKeyFromDatabase() method in AppConfig to call backend API
    status: completed
  - id: test-implementation
    content: "Test the flow: login -> fetch key -> cache -> use in OpenAIService"
    status: in_progress
---

# Store Gemini API Key in Database

## Overview

Currently, the Gemini API key is hardcoded in `lib/core/config/app_config.dart` at line 13. This plan will:

1. Create a database table to store the API key
2. Add a backend API endpoint to fetch the API key (or include it in login response)
3. Update `AppConfig.getGeminiApiKey()` to fetch from database after login
4. Update the login flow to fetch and cache the API key
5. Maintain fallback to hardcoded default if database fetch fails

## Database Changes

### Create `app_config` table

Create a new table to store application configuration including the Gemini API key:

```sql
CREATE TABLE app_config (
  id SERIAL PRIMARY KEY,
  config_key VARCHAR(100) UNIQUE NOT NULL,
  config_value TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert initial API key
INSERT INTO app_config (config_key, config_value, description) 
VALUES ('gemini_api_key', 'AIzaSyBB-nGNXzlo399N1viNLq011V4YJJDWzBg', 'Google Gemini API key for AI features');
```

## Code Changes

### 1. Update `lib/core/config/app_config.dart`

- Modify `getGeminiApiKey()` to check database first (after login), then SharedPreferences, then environment variable, then hardcoded default
- Add a new method `fetchGeminiApiKeyFromDatabase()` that calls the backend API
- Add caching mechanism to avoid repeated database calls

### 2. Update `lib/core/services/auth_service.dart`

- After successful login (line 84), fetch the API key from the database
- Cache the API key in SharedPreferences for offline use
- Handle errors gracefully with fallback to default

### 3. Backend API Endpoint (if needed)

- Option A: Include `geminiApiKey` in the login response (`/auth/login`)
- Option B: Create a new endpoint `/config/gemini-api-key` that returns the active API key
- The endpoint should return the key from the `app_config` table where `config_key = 'gemini_api_key'` and `is_active = true`

### 4. Update `lib/core/services/openai_service.dart`

- No changes needed - it already uses `AppConfig.getGeminiApiKey()` which will now fetch from database

## Implementation Details

### Priority Order for API Key Retrieval:

1. Database (fetched after login, cached in SharedPreferences)
2. SharedPreferences (cached value from previous login)
3. Environment variable (`GEMINI_API_KEY`)
4. Hardcoded default (fallback)

### Error Handling:

- If database fetch fails, log warning and use fallback
- If API key is null/empty from database, use fallback
- Ensure app continues to work even if database is unavailable

### Caching Strategy:

- Cache API key in SharedPreferences after successful database fetch
- Refresh cache on each login
- Clear cache on logout (optional - may want to keep for offline use)

## Files to Modify

1. `lib/core/config/app_config.dart` - Update `getGeminiApiKey()` method
2. `lib/core/services/auth_service.dart` - Add API key fetch after login
3. `lib/core/services/api_service.dart` - May need to add method for config endpoint

## Testing Considerations

- Test with valid API key in database
- Test with invalid/expired API key in database (should fallback)
- Test with database unavailable (should use cached/fallback)
- Test login flow to ensure API key is fetched and cached
- Verify OpenAIService still works correctly with database-fetched key