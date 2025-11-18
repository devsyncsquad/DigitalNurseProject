import { IsString, MinLength, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: '+923001234567', description: 'Phone number with country code (e.g., +92 for Pakistan)' })
  @IsString()
  @Matches(/^\+92\d{10}$/, { message: 'Phone number must be in format +92XXXXXXXXXX (Pakistan format)' })
  phone!: string;

  @ApiProperty({ example: 'StrongPassword123!' })
  @IsString()
  @MinLength(8)
  password!: string;
}
