import fs from 'fs';
import { parse } from 'dotenv';

export interface IEnvironment {
  DUELIST_KING_DEPLOY_MNEMONIC: string;
  DUELIST_KING_RPC: string;
  PRIVATE_KEY: string;
  DUELIST_KING_FORK: boolean;
}

function clean(config: any): any {
  const entries = Object.entries(config);
  const cleaned: any = {};
  for (let i = 0; i < entries.length; i += 1) {
    const [k, v] = entries[i] as [string, string];
    if (k === 'DUELIST_KING_FORK') {
      cleaned[k] = v.trim().toLowerCase() === 'true';
    } else {
      cleaned[k] = v.trim();
    }
  }
  cleaned.DUELIST_KING_FORK = cleaned.DUELIST_KING_FORK || false;
  return cleaned;
}

export const env: IEnvironment = fs.existsSync(`${__dirname}/.env`)
  ? clean(parse(fs.readFileSync(`${__dirname}/.env`)) as any)
  : {
      DUELIST_KING_FORK: false,
      PRIVATE_KEY: '0x'.padEnd(66, '0'),
      DUELIST_KING_DEPLOY_MNEMONIC: 'baby nose young alone sport inside grain rather undo donor void exotic',
      DUELIST_KING_RPC: 'http://localhost:8545',
    };
