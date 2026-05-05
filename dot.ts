#!/usr/bin/env bun

import { defineCommand, runMain } from "citty";
import { linkCommand, unlinkCommand } from "./src/commands/link.ts";
import { infoCommand, configureCommand, enableCommand, disableCommand } from "./src/commands/info.ts";
import { updateCommand } from "./src/commands/update.ts";
import { assetsCommand } from "./src/commands/assets.ts";
import { docsCommand } from "./src/commands/docs.ts";
import { toolsCommand } from "./src/commands/tools/index.ts";

const main = defineCommand({
  meta: {
    name: "dot",
    description: "Dotfiles manager — link packages, update system, sync assets, run tools",
  },
  subCommands: {
    link: linkCommand,
    unlink: unlinkCommand,
    info: infoCommand,
    configure: configureCommand,
    enable: enableCommand,
    disable: disableCommand,
    update: updateCommand,
    assets: assetsCommand,
    docs: docsCommand,
    tools: toolsCommand,
  },
});

runMain(main);
