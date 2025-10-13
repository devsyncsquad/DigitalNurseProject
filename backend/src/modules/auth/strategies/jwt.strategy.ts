import { Strategy as JwtStrategy, ExtractJwt, StrategyOptions } from 'passport-jwt';
import { env } from '../../../config/env';
import { prisma } from '../../../config/database';
import { JwtPayload } from '../../../utils/jwt.utils';

const options: StrategyOptions = {
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  secretOrKey: env.JWT_SECRET,
};

export const jwtStrategy = new JwtStrategy(options, async (payload: JwtPayload, done) => {
  try {
    const user = await prisma.user.findUnique({
      where: { userId: BigInt(payload.userId) },
    });

    if (!user) {
      return done(null, false);
    }

    return done(null, user);
  } catch (error) {
    return done(error, false);
  }
});
