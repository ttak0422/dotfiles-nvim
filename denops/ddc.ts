import { BaseConfig, ConfigArguments } from "jsr:@shougo/ddc-vim@~7.1.0/config";

export class Config extends BaseConfig {
  override config(
    { contextBuilder, denops }: ConfigArguments,
  ): Promise<void> {
    contextBuilder.patchGlobal({
      ui: "pum",
      uiParams: {
        pum: {
          insert: false,
        },
      },
      autoCompleteDelay: 50,
      autoCompleteEvents: [
        "InsertEnter",
        "TextChangedI",
        "TextChangedP",
        "CmdlineEnter",
        "CmdlineChanged",
        "TextChangedT",
      ],
      backspaceCompletion: false,
      sources: [
        "denippet",
        "lsp",
        "around",
        "vsnip",
      ],
      cmdlineSources: {
        ":": ["cmdline", "cmdline-history", "around"],
        "@": [],
        ">": [],
        "/": ["around", "line"],
        "?": ["around", "line"],
        "-": ["around", "line"],
        "=": ["input"],
      },
      sourceOptions: {
        _: {
          ignoreCase: true,
          matchers: [
            "matcher_fuzzy",
          ],
          sorters: ["sorter_rank", "sorter_fuzzy"],
          converters: [
            "converter_remove_overlap",
            "converter_truncate",
            "converter_fuzzy",
          ],
          dup: "ignore",
          minKeywordLength: 2,
          timeout: 1000,
        },
        around: {
          mark: "[AROUND]",
        },
        line: {
          mark: "[LINE]",
          maxItems: 50,
        },
        file: {
          mark: "[FILE]",
          isVolatile: true,
          forceCompletionPattern: "\\S/\\S*",
        },
        buffer: {
          mark: "[BUFFER]",
        },
        skkeleton: {
          mark: "[SKK]",
          matchers: ["skkeleton"],
          sorters: [],
          isVolatile: true,
        },
        lsp: {
          mark: "[LSP]",
          forceCompletionPattern: "\\.\\w*|::\\w*|->\\w*",
          dup: "keep",
          minAutoCompleteLength: 1,
          sorters: [
            "sorter_lsp-detail-size",
            "sorter_lsp-kind",
            "sorter_fuzzy",
          ],
        },
        necovim: {
          mark: "[VIM]",
        },
        cmdline: {
          mark: "[CMD]",
          // forceCompletionPattern: "\\S/\\S*|\\.\\w*",
        },
        input: {
          mark: "[INPUT]",
          forceCompletionPattern: "\\S/\\S*",
          isVolatile: true,
        },
        "cmdline-history": {
          mark: "[HIST]",
          sorters: [],
        },
        vwnip: {
          mark: "[VSNIP]",
        },
        omni: {
          mark: "[OMNI]",
        },
        denippet: {
          mark: "[SNIP]",
        },
      },
      sourceParams: {
        buffer: {
          requireSameFiletype: false,
          limitBytes: 50000,
          fromAltBuf: true,
          forceCollect: true,
        },
        file: {
          filenameChars: "[:keyword:].",
        },
      },
      filterParams: {
        converter_fuzzy: {
          hlGroup: "PmenuFuzzyMatch",
        },
      },
      postFilters: ["sorter_head"],
    });

    contextBuilder.patchFiletype("vim", {
      specialBufferCompletion: true,
      sources: ["lsp", "necovim", "around"],
    });

    for (const filetype of ["typescript", "javascript"]) {
      contextBuilder.patchFiletype(filetype, {
        sourceOptions: {
          _: {
            keywordPattern: "#?[a-zA-Z_][0-9a-zA-Z_]*",
          },
        },
      });
    }

    return Promise.resolve();
  }
}
