import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, VerifyCallback } from 'passport-google-oauth20';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    const clientID = configService.get<string>('GOOGLE_CLIENT_ID');
    const clientSecret = configService.get<string>('GOOGLE_CLIENT_SECRET');
    const callbackURL = configService.get<string>('GOOGLE_CALLBACK_URL');

    // Only initialize if all required credentials are provided
    if (!clientID || !clientSecret || !callbackURL) {
      // Use placeholder values to prevent OAuth2Strategy error
      // The strategy won't be used if credentials are missing
      super({
        clientID: 'placeholder',
        clientSecret: 'placeholder',
        callbackURL: 'placeholder',
        scope: ['email', 'profile'],
      });
    } else {
      super({
        clientID,
        clientSecret,
        callbackURL,
        scope: ['email', 'profile'],
      });
    }
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    profile: any,
    done: VerifyCallback,
  ): Promise<any> {
    // Check if credentials are configured
    const clientID = this.configService.get<string>('GOOGLE_CLIENT_ID');
    if (!clientID || clientID === 'placeholder') {
      return done(new Error('Google OAuth is not configured'), undefined);
    }

    const { id, emails, displayName } = profile;

    const user = await this.authService.validateGoogleUser({
      googleId: id,
      email: emails[0].value,
      name: displayName,
    });

    done(null, user);
  }
}
