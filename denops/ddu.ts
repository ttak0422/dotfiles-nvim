import {
  BaseConfig,
  ConfigArguments,
} from "jsr:@shougo/ddu-vim@~10.0.0/config";
import { Params as FfParams } from "jsr:@shougo/ddu-ui-ff@~2.0.0";
import { Params as FilerParams } from "jsr:@shougo/ddu-ui-filer@~1.5.0";
import { type Denops } from "jsr:@denops/std@~7.4.0";
import * as fn from "jsr:@denops/std@~7.4.0/function";

export class Config extends BaseConfig {
  override config({
    contextBuilder,
    setAlias,
  }: ConfigArguments): Promise<void> {
    setAlias("files", "source", "file_fd", "file_external");
    setAlias("mru", "source", "mru", "mr");
    setAlias("mrw", "source", "mrw", "mr");
    setAlias("mrr", "source", "mrr", "mr");
    setAlias("mrd", "source", "mrd", "mr");

    contextBuilder.patchGlobal({
      sources: ["file"],
      ui: "ff",
      profile: false,
      // TODO:
      uiOptions: {},
      uiParams: {
        ff: {
          prompt: " ",
          autoAction: {
            name: "preview",
            delay: 250, // same as telescope.nvim
          },
          filterSplitDirection: "floating",
          floatingBorder: "none",
          highlights: {
            filterText: "Statement",
            floating: "Normal",
            floatingBorder: "Special",
          },
          maxHighlightItems: 50,
          onPreview: async (args: { denops: Denops; previewWinId: number }) => {
            await fn.win_execute(args.denops, args.previewWinId, "normal! zt");
          },
          previewFloating: true,
          previewFloatingBorder: "single",
          updateTime: 0,
          winWidth: 100,
        } as Partial<FfParams>,
        filer: {
          previewFloating: true,
          sort: "filename",
          sortTreesFirst: true,
          split: "no",
          toggle: true,
        } as Partial<FilerParams>,
      },
      sourceOptions: {
        _: {
          matchers: ["matcher_fzf"],
          sorters: ["sorter_fzf"],
          smartCase: true,
        },
        mru: {
          matchers: ["matcher_ignore_files", "matcher_relative", "matcher_fzf"],
        },
        mrw: {
          matchers: ["matcher_ignore_files", "matcher_relative", "matcher_fzf"],
        },
        mrr: {
          matchers: ["matcher_ignore_files", "matcher_relative", "matcher_fzf"],
        },
        mrd: {
          matchers: ["matcher_ignore_files", "matcher_relative", "matcher_fzf"],
        },
        file: {
          matchers: ["matcher_substring", "matcher_hidden"],
          sorters: ["sorter_alpha"],
          converters: ["converter_hl_dir"],
          smartCase: true,
        },
        rg: {
          matchers: [
            "converter_display_word",
            "matcher_substring",
            "matcher_files",
          ],
          sorters: ["sorter_alpha"],
        },
        ghq: {
          defaultAction: "cd",
        },
      },
      sourceParams: {
        mru: {
          kind: "mru",
        },
        mrw: {
          kind: "mrw",
        },
        mrr: {
          kind: "mrr",
        },
        mrd: {
          kind: "mrd",
        },
        file: {
          new: false,
        },
        file_fd: {
          cmd: ["fd", ".", "-H", "-t", "f", "--exclude", ".git"],
        },
      },
      filterParams: {
        matcher_substring: {
          highlightMatched: "Search",
        },
        matcher_fzf: {
          highlightMatched: "Search",
        },
        matcher_ignore_files: {
          ignoreGlobs: [],
          ignorePatterns: [/.*\/COMMIT_EDITMSG$/],
        },
        converter_hl_dir: {
          hlGroup: ["Directory", "Keyword"],
        },
      },
      kindOptions: {
        file: {
          defaultAction: "open",
        },
        url: {
          defaultAction: "browse",
        },
      },
      kindParams: {},
      actionOptions: {
        narrow: {
          quit: false,
        },
        tabopen: {
          quit: false,
        },
      },
    });

    return Promise.resolve();
  }
}
