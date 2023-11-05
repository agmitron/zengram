import type { GlobalState } from '../types';

import configExample from '../../../zengram.config.json';

export { configExample };

// TODO

export const isAllowed = (chatId: string) => {
  const allChats = new Set(configExample.folders.flatMap(({ chats }: any) => chats)); // TODO

  return allChats.has(chatId);
};

export const overrideChats = <T extends GlobalState>(
  global: T,
  // config: typeof configExample
): T => {
  const allowedChats = global.chats.listIds.active?.map((id) => isAllowed(id));

  return {
    ...global,
    chats: allowedChats,
  };
};

export const overrideFolders = <T extends GlobalState>(
  global: T,
  config: typeof configExample,
): T => {
  const chatFolders = {
    byId: config.folders.reduce(
      (acc: any, f: any) => ({ // TODO
        ...acc,
        [f.id]: {
          id: f.id,
          title: f.title,
          channels: false,
          pinnedChatIds: [],
          includedChatIds: f.chats,
          excludedChatIds: [],
        },
      }),
      {},
    ),
    orderedIds: config.folders.map((f: any) => f.id),
  };

  return {
    ...global,
    chatFolders,
  };
};
