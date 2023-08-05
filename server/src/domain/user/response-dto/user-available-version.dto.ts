import { SystemConfigImmichVersion } from '@app/domain/system-config/dto/system-config-version.dto';
import { IsBoolean, IsOptional } from 'class-validator';

export class AvailableVersionResponseDto {
  @IsBoolean()
  available!: boolean;

  @IsOptional()
  availableVersion?: SystemConfigImmichVersion;
}
