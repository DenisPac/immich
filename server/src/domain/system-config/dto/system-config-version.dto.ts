import { IsNumber } from 'class-validator';

export class SystemConfigImmichVersion {
  @IsNumber()
  major!: number;
  @IsNumber()
  minor!: number;
  @IsNumber()
  patch!: number;
}
