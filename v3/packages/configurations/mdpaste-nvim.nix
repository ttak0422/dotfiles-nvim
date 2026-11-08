{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  luaCheck,
  inputs',
}:
with sources;
{
  plugin = sources.mdpaste-nvim;
  doc = ''
    # mdpaste.nvim

    ## 概要
    クリップボードの HTML を Markdown に変換して貼り付ける。

    ## 主な機能
    - リンク・画像・強調・コード・見出し・リストを変換。
    - HTML がない場合は通常の `"+` レジスター貼り付けにフォールバック。

    ## 使い方
    `:MdPaste` または `<Plug>(mdpaste)` で貼り付ける。変換だけを行う場合は `require("mdpaste").html_to_md(html)` を使う。

    ## 要件
    Neovim 0.10 以降。macOS は組み込みの osascript、Wayland は wl-paste、X11 は xclip。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/ttak0422/mdpaste.nvim/blob/78da70ba74b39f32a98fcd602ad5cbfe2ef1e1d6/README.md)
  '';
  tests.mdpaste-conversion = luaCheck {
    name = "mdpaste-conversion";
    script = ''
      local convert = require("mdpaste").html_to_md
      assert(convert('<a href="https://example.test/docs"><strong>Docs</strong> &amp; help</a>')
        == "[**Docs** & help](https://example.test/docs)", "links must preserve nested emphasis and decode entities")
      assert(convert("<h2>Title</h2><ul><li>one</li><li>two</li></ul>") == "## Title\n\n- one\n- two",
        "headings and lists must retain Markdown block boundaries")
      assert(convert('<img src="local.png" alt="Diagram"><br><code>x &lt; 2</code>') == "![Diagram](local.png)\n`x < 2`",
        "images, line breaks and inline code must convert without clipboard access")
      assert(convert('<style>hidden</style><script>hidden()</script><!-- hidden --><p>Visible&nbsp;text</p>')
        == "Visible text", "script, style and comment content must not leak into pasted Markdown")
      assert(convert("") == "", "empty clipboard fragments must stay empty")
    '';
  };
}
