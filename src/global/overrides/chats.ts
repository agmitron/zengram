import type { GlobalState } from '../types';

// TODO
export const configExample = {
  chats: {
    allowed: new Set(['-1001674845728']),
  },
};

export const overrideChats = <T extends GlobalState>(
  global: T,
  config: typeof configExample,
): T => {
  const allowedChats = global.chats.listIds.active?.map((id) => config.chats.allowed.has(id));

  return {
    ...global,
    chats: allowedChats,
  };
};
