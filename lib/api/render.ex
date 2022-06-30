defmodule Api.Render do
  def markdown(text, title \\ "") do
    {:ok, html_doc, _} = Earmark.as_html(text)
    style = md_style2()

    """
    <!doctype html>
    <html>
    <head>
    <meta charset="utf-8"/>
    <title>Matr1x #{title}</title>
    <style type="text/css">
    #{style}
    </style>
    </head>
    <body>
    <div id = "content">
    #{html_doc}
    </div>
    </body>
    </html>
    """
  end

  defp md_style1 do
    """
    * {
      color: #555;
      font-family: -apple-system-font, sans-serif;

    }

    p{
      letter-spacing: 1px !important;
      line-height: 28px !important;
      min-height: 1em !important;
      box-sizing: border-box !important;
      word-wrap: break-word !important;
      text-align: left;
      margin: 20px 0px !important;
    }

    blockquote {
        border-left: 10px solid rgba(128,128,128,0.075);
        background-color: rgba(128,128,128,0.05);
        padding: 13px 15px !important;
        margin: 0px;
    }

    blockquote p {
      color: #898989;
      margin: 0px;
    }

    strong {
        font-weight: 700;
        color: #bf360c;
    }

    body {
      font-size: 15px;
      padding: 0 30px;
    }

    pre {
      background-color: #f8f8f8;
      border-radius: 3px;
      word-wrap: break-word;
      padding: 12px 13px;
      font-size: 13px;
      color: #898989;
    }

    h1,h2,h3,h4,h5,h6 {
        word-break: break-all !important;
        margin: 20px 0;
        line-height: 1.2;
        text-align: left;
        font-weight: bold;
        // padding-left: 15px;
    }

    h1 {
        // border-left: 6px solid #71BA51 !important;
        font-size: 20px !important;
    }

    h2 {
        // border-left: 4px solid #71BA51 !important;
        font-size: 18px !important;
    }

    h3 {
        font-size: 16px;
      // border-left: 4px solid #71BA51 !important;
    }

    h4 {
      font-size: 15px;
      // border-left: 2px solid #71BA51 !important;
    }

    a {
      color: #4183C4 !important;
      text-decoration: none !important;
    }

    ul, ol {
      padding-left: 30px;
    }

    li {
      line-height: 24px;
    }

    hr {
        height: 4px;
        padding: 0;
        margin: 16px 0;
        background-color: #e7e7e7;
        border: 0 none;
        overflow: hidden;
        box-sizing: content-box;
        border-bottom: 1px solid #ddd;
    }

    pre {
     background: #f2f2f2 !important;
     padding: 12px 13px;
     overflow: auto;
    }

    code {
      color: #a71d5d;
      overflow: auto;
      background-color: rgba(241, 236, 229, 0.34);
      padding: 0 0.2em;
    }

    pre code {
      color: #a71d5d;
      padding: 0;
      background-color: none;
    }
    """
  end

  defp md_style2() do
    """
    :root {
      --main-color: rgba(128, 30, 255, 1);
      --shadow-color : rgb(178, 80, 255);
      --transplate-color : rgba(128, 30, 255, 0.1);
      --dark-color : rgb(70, 18, 137);
      --light-color : rgb(248, 242, 255);
      --font-color : rgb(12, 12, 12);
      --base-font : "Glow Sans", "Microsoft YaHei", serif;
      --title-font: "Roboto Slab", "Times", serif;
      --blockquote-font : "Times", "Roboto Slab", serif;
      --blockquote-color : rgba(117, 117, 117, 0.9);
      --monospace: "Cascadia code", "Courier New", monospace;

      /* --background : url("https://cdn.jsdelivr.net/gh/LSTM-Kirigaya/KImage/Img/2k.jpg"); */

      --quote-title-font-size : 0.9em;
      --quote-tag-font-size : 1.1em;

      /* typora GUI config */
      --sidebar-font-color : black;
      --main-panel-font-color : black;
    }

    /* global setting */
    body {
      /* background-color: rgb(255, 255, 255); */
    }

    html {
    -webkit-text-size-adjust: 100%;
    -ms-text-size-adjust: 100%;
    text-rendering: optimizelegibility;
    -webkit-font-smoothing: initial;
    }


    /* write is a wrapper of writable region */
    #write {
      position: static;
      /* width: 90%; */
      max-width: 1000px;
      min-height: calc(100vh - 6rem);
    min-width: calc(100vw - 45rem);
      line-height: 1.6;
      transform: none;
      height: auto;
      caret-color: var(--main-color);
    }

    #write h1, h2, h3, h4, h5, h6 {
      color: var(--font-color);
      font-family: var(--title-font);
      font-weight: 800;
      line-height: 1.5;
      margin: 0 0 1em 0;
    }

    #write h1 {
      font-size: 40px;
      margin: 0 0 1.0em 0;
      line-height: 1.3;
      border-bottom: solid 3px var(--main-color);
      width: fit-content;
    }

    #write h2 {
      font-size: 28px;
      border-radius: .5em;
      width: fit-content;
    }

    #write h2::before {
      content: "H2";
      border-radius: .3em;
      font-size: .8em;
      padding: 3px 7px;
      margin-right: 15px;
      background-color: var(--main-color);
      color: white;
      float: none;
      position: relative;
      top: 0;
      left: 0;
      vertical-align: baseline;
      border-width: 0;
    }

    #write h3 {
      font-size: 24px;
      border-radius: .3em;
      width: fit-content;
    }

    #write h3::before {
      content: "H3";
      color : white;
      font-size: 0.8em;
      background-color: var(--main-color);
      border-radius: .3em;
      margin-right: 12px;
      padding: 4px 7px;
      float: none;
      position: relative;
      top: 0;
      left: 0;
      vertical-align: baseline;
      border-width: 0;
    }

    #write h4 {
      font-size: 20px;
    }

    #write h5 {
      font-size: 16px;
    }

    #write hr {
      width: 60%;
      text-align:center;
      border-bottom: solid 1.8px var(--main-color);
      margin: 4.5em auto;
    }


    #write img {
      border-radius: 1.5em !important;
      box-shadow: 0 0 10px 3px rgba(134, 136, 137, 0.8);
      transition: all 0.3s linear;
      -moz-transition: all 0.3s linear;
      -webkit-transition: all 0.3s linear;
    }

    /* #write img:hover {
      box-shadow: 0 0 10px 5px var(--shadow-color);
      transition: all 0.3s linear;
      -moz-transition: all 0.3s linear;
      -webkit-transition: all 0.3s linear;
    } */


    #write blockquote {
      padding: 10px 10px;
      font-size: var(--quote-title-font-size);
      color: var(--blockquote-color);
      border-left: 6px solid var(--main-color);
      background: var(--light-color);
      border-radius : 0.5em;
      font-family: var(--blockquote-font);
      line-height: 35px;
    }

    #write blockquote span {
      word-break: break-all;
    }

    #write blockquote h1 {
      font-weight: 200;
      font-size: var(--quote-tag-font-size);
      border-bottom: none;
      font-family: var(--base-font);
      line-height: 35px;
    }

    #write blockquote h1::before {
      content: "Tips";
      background-color: var(--main-color);
      font-family: var(--title-font);
      color: white;
      font-size: var(--quote-tag-font-size);
      border-radius: .3em;
      padding: 3px 7px;
      margin-right: 15px;
    }

    #write blockquote h2 {
      font-weight: 200;
      font-size: var(--quote-tag-font-size);
      font-family: var(--base-font);
      line-height: 35px;
    }

    #write blockquote h2::before {
      content: "Warning";
      background-color: rgb(207, 210, 16);
      font-family: var(--title-font);
      color: white;
      font-size: var(--quote-tag-font-size);
      border-radius: .3em;
      padding: 3px 7px;
      margin-right: 15px;
    }

    #write blockquote h3 {
      font-weight: 200;
      font-size: var(--quote-tag-font-size);
      font-family: var(--base-font);
      line-height: 35px;
    }

    #write blockquote h3::before {
      content: "Error";
      background-color: rgb(224, 66, 66);
      font-family: var(--title-font);
      color: white;
      font-size: var(--quote-tag-font-size);
      border-radius: .3em;
      padding: 3px 7px;
      margin-right: 15px;
      float: none;
      position: relative;
      top: 0;
      left: 0;
      vertical-align: baseline;
      border-width: 0;
    }

    #write blockquote h4 {
      font-weight: 200;
      font-size: var(--quote-tag-font-size);
      font-family: var(--base-font);
      line-height: 35px;
    }

    #write blockquote h4::before {
      content: "Remind";
      background-color: var(--shadow-color);
      font-family: var(--title-font);
      color: white;
      font-size: var(--quote-tag-font-size);
      border-radius: .3em;
      padding: 3px 7px;
      margin-right: 15px;
      float: none;
      position: relative;
      top: 0;
      left: 0;
      vertical-align: baseline;
      border-width: 0;
    }

    #write blockquote h5 {
      font-weight: 200;
      font-size: var(--quote-tag-font-size);
      font-family: var(--base-font);
      line-height: 35px;
    }

    #write blockquote h5::before {
      content: "Remind";
      background-color: var(--shadow-color);
      font-family: var(--title-font);
      color: white;
      font-size: var(--quote-tag-font-size);
      border-radius: .3em;
      padding: 3px 7px;
      margin-right: 15px;
      float: none;
      position: relative;
      top: 0;
      left: 0;
      vertical-align: baseline;
      border-width: 0;
    }


    /* code block */
    #write pre.md-fences {
    padding: 1rem 0.5rem 1rem;
    display: block;
    -webkit-overflow-scrolling: touch;
    /* box-shadow: 0 0 6px 2px rgba(151, 151, 151, 0.9); */
      /* border-top: rgb(51, 51, 51) solid 35px; */
      border-top: rgb(244, 244, 244) solid 35px;
      background-color: rgb(244, 244, 244);
    }


    pre.md-fences::before {
    content: ' ';
    background: var(--main-color);
    box-shadow: 23px 0 rgb(128, 128, 128), 45px 0 gray;
    border-radius: 50%;
    margin-top: -2.3rem;
    position: absolute;
    left: 15px;
    height: 12px;
    width: 12px;
    }

    #write pre.md-fences {
    line-height: 1.5rem;
    font-size: .9rem;
    font-weight: 300;
    border-radius: .7em;
      font-family: var(--monospace) !important;
    }

    /* inline code */
    code {
      margin: 0 2px;
      padding: 4px 6px;
      color: #666363;
      white-space: pre-wrap;
      background: var(--light-color);
      border-radius: 8px;
    }

    #write blockquote code {
      margin: 0 2px;
      padding: 4px 6px;
      color: white;
      white-space: pre-wrap;
      background: var(--main-color);
      border-radius: 8px;
    }

    kbd,
    samp,
    tt,
    var {
    font-family: var(--monospace) !important;
    }


    /* YAML */
    pre.md-meta-block {
      font-size: .8rem;
      min-height: .8rem;
      white-space: pre-wrap;
      background: var(--main-color);
      display: block;
      overflow-x: hidden;
      padding: 15px;
      font-family: var(--monospace);
      border-radius: 1.2em;
      color: white;
      caret-color: white;
    }


    /* Math */
    #math-inline-preview-content .MathJax {
      color: white !important;
    }

    /* table */
    #write table
    {
      width: 95%;
      border-collapse: collapse;
      text-align: center;
      font-family: var(--monospace);
      margin: 20px;
    }
    #write table td, table th
    {
      border: 1px solid transparent;
      color: rgb(18, 18, 18);
      height: 30px;
      padding: 10px;
      border-radius: .5em;
      transition: all 0.3s linear;
      -moz-transition: all 0.3s linear;
      -webkit-transition: all 0.3s linear;
    }
    #write table td {
      font-family: var(--title-font);
    }
    #write table thead th
    {
      background-color: var(--shadow-color);
      font-size: 20px;
      color: white;
      font-weight: bolder;
      width: 100px;
      text-align: center;
      vertical-align: middle;
      padding: 10px;
    }
    table tr:nth-child(odd)
    {
      background: white;
    }
    table tr:nth-child(even)
    {
      background: var(--light-color);
    }
    table td:hover {
    background-color: var(--shadow-color) !important;
    color: white !important;
    box-shadow: 0 0 10px 5px var(--shadow-color);
    transition: all 0.3s linear;
    -moz-transition: all 0.3s linear;
    -webkit-transition: all 0.3s linear;
    }


    /* main element consisting of your text */
    p {
      color: var(--font-color);
      margin: 0 0 2em 0;
      font-weight: 500;
      line-height: 1.6;
      font-family: var(--base-font);
    }

    a {
      color: var(--main-color);
      font-weight: 500;
      text-decoration: none;
      text-decoration-style: none;
      cursor: pointer;
      padding: 0 3px 0 3px;
    }


    /* list */

    ol,
    ul {
    padding-left: 2em;
    line-height: 2;
    }

    ul>li>ul>li {
      list-style-type: circle;
    }

    ul>li>ul>li>ul>li {
      list-style-type: square;
    }


    iframe {
      border-radius: 1.2em;
      box-shadow: 0 0 8px 3px rgba(181, 181, 182, 0.9);
    }


    /* checkbox */
    .md-task-list-item:hover > input:before,
    input[type='checkbox']:hover:before {
    opacity: 1;
    transition: 0.3s;
    background-color: var(--shadow-color);
    }

    .task-list-item input::before {
      content: "";
      display: inline-block;
    border-radius: .3em;
      vertical-align: middle;
      border: 1.2px solid var(--main-color);
      background-color: #ffffff;
    width: 1.1rem;
      height: 1.1rem;
    margin-left: -0.1rem;
      margin-right: 0.1rem;
      margin-top: -0.68rem;
    }

    .task-list-item input:checked::before {
      padding-left: 0.125em;
      content: '✔';
      color:white;
    background-color: var(--main-color);
      font-size: 0.8rem;
      line-height: 0.95rem;
      margin-top: -0.68rem;
    transition: background-color 200ms ease-in-out;
    }





    #footer-word-count-label {
      font-family: var(--title-font) !important;
      color: white;
      padding: 1px 8px;
      border-radius: 1.0em;
      background-color: var(--main-color);
    }

    /* bg color when text is selected */
    div::selection {
    background: var(--main-color);
    color: white;
    }

    div::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    div::-webkit-selection {
    background: var(--main-color);
    color: white;
    }

    blockquote::selection {
    background: var(--main-color);
    color: white;
    }

    blockquote::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    blockquote::-webkit-selection {
    background: var(--main-color);
    color: white;
    }

    p::selection {
    background: var(--main-color);
    color: white;
    }

    p::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    p::-webkit-selection {
    background: var(--main-color);
    color: white;
    }

    label::selection {
    background: var(--main-color);
    color: white;
    }

    label::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    label::-webkit-selection {
    background: var(--main-color);
    color: white;
    }

    span::selection {
    background: var(--main-color);
    color: white;
    }

    span::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    span::-webkit-selection {
    background: var(--main-color);
    color: white;
    }

    h1::selection {
    background: var(--main-color);
    color: white;
    }

    h1::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    h1::-webkit-selection {
    background: var(--main-color);
    color: white;
    }

    h2::selection {
    background: var(--main-color);
    color: white;
    }

    h2::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    h2::-webkit-selection {
    background: var(--main-color);
    color: white;
    }

    h3::selection {
    background: var(--main-color);
    color: white;
    }

    h3::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    h3::-webkit-selection {
    background: var(--main-color);
    color: white;
    }

    h4::selection {
    background: var(--main-color);
    color: white;
    }

    h4::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    h4::-webkit-selection {
    background: var(--main-color);
    color: white;
    }

    h5::selection {
    background: var(--main-color);
    color: white;
    }

    h5::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    h5::-webkit-selection {
    background: var(--main-color);
    color: white;
    }

    code::selection {
    background: var(--main-color);
    color: white;
    }

    code::-moz-selection {
    background: var(--main-color);
    color: white;
    }

    code::-webkit-selection {
    background: var(--main-color);
    color: white;
    }


    /* outside */


    #megamenu-content {
      background-color: rgba(255, 255, 255, 0.1);
    }

    #megamenu-menu-panel {
      font-family: var(--title-font);
      padding: 10px;
    }

    .megamenu-menu-panel {
      padding: 10px;
    }


    .megamenu-menu-header-title-menu {
      color: var(--sidebar-font-color);
    }

    .megamenu-menu-header-title-back {
      color: var(--sidebar-font-color);
    }


    /* sidebar */
    .megamenu-menu-header {
      width: 60%;
      text-align:center;
      border-bottom: solid 3px var(--main-color);
    }
    #megamenu-menu-sidebar {
      background-color: rgba(255, 255, 255, 0.1);
      color: var(--sidebar-font-color);
      box-shadow: 0 0 8px 4px rgb(100 100 100 / 80%);
      margin-top: 3%;
      height: 92%;
      border-radius: 0 4em 4em 0;
    }
    #megamenu-back-btn {
      border-radius: 1.2em;
      color: var(--main-color);
      transition: all linear .3s;
      padding: 0 0 10px;
    }

    #megamenu-back-btn:hover {
      background-color: var(--main-color);
      color: white;
      border: 2px solid white;
      transition: all linear .3s;
    }

    #megamenu-menu-list > li {
      transition: all linear .3s;
    }

    #megamenu-menu-list > li:hover {
      transition: all linear .3s;
      border-top-left-radius: 1.2em;
      border-bottom-left-radius: 1.2em;
    }

    #megamenu-menu-list > li:focus {
      transition: all linear .3s;
      color : white;
      background-color: var(--shadow-color);
      width: fit-content;
      border-top-right-radius: 1.2em;
      border-bottom-right-radius: 1.2em;
    }

    .dropdown-menu .divider {
      width: 30%;
      color: var(--main-color);
      background-color: var(--main-color);
    }
    .megamenu-menu-list li a {
      transition: all linear .3s;
      width: fit-content;
      padding-right: 60px;
    }

    .megamenu-menu-list li a:hover {
      transition: all linear .3s;
      color: white !important;
      background-color: var(--main-color) !important;
      border-bottom-right-radius: 2em;
      border-top-right-radius: 2em;
    }

    .megamenu-menu-list li a.active, .megamenu-menu-list:not(.saved) li a:hover {
      color: white !important;
      background-color: var(--main-color) !important;
      border-bottom-right-radius: 2em;
      border-top-right-radius: 2em;
    }


    /* open */
    #m-open-local,
    #m-import-local {
      border-radius: 1.2em;
    }

    #m-open-local:hover,
    #m-import-local:hover {
      border: 1px solid var(--shadow-color);
    }

    #recent-file-panel-search-input {
      border-radius: 1.2em;
      transition: all linear .3s;
      font-family: var(--title-font);
    }
    #recent-file-panel-action-btn {
      border-radius: 1.2em;
    }

    #recent-file-panel-search-input:hover {
      transition: all linear .3s;
      box-shadow: 0 0 10px 3px var(--shadow-color);
    }

    #recent-file-panel-search-input:focus {
      transition: all linear .3s;
      color: white;
      border: none;
      background-color: var(--shadow-color);
    }

    /* side bar Ctrl Shift 2 */
    /* .typora-node.pin-outline:not(.megamenu-opened):not(.typora-sourceview-on) #typora-sidebar {
      display: block;
      left: 0;
      transition: left .3s;
      border-radius: 0em 3em 3em 0em;
      box-shadow: 0 0 8px 3px rgb(100 100 100 / 80%);
      margin-top: 20px;
      margin-bottom: 5%;
      height: 95%;
      padding-right: 10px;
    } */

    .info-panel-tab-border {
      color: var(--main-color) !important;
      background-color: var(--main-color) !important;
    }

    .outline-content {
      padding: 3px 18px 3px 0;
    }

    .outline-item {
      margin-left: -20px;
      margin-right: -20px;
      border-left: 20px solid transparent;
      border-right: 16px solid transparent;
    }

    .outline-item:hover {
      background-color: var(--shadow-color);
      color: white;
    }

    .active-tab-files  #info-panel-tab-file .info-panel-tab-title {
      background-color: var(--main-color);
      color: white;
      padding: 5px 5px;
      border-radius: 1.2em;
      transition: all linear .3s;
    }

    .active-tab-outline #info-panel-tab-outline .info-panel-tab-title {
      background-color: var(--main-color);
      color: white;
      padding: 5px 5px;
      border-radius: 1.2em;
      transition: all linear .3s;
    }

    .ty-show-search #info-panel-tab-search  .info-panel-tab-title {
      background-color: var(--main-color);
      color: white;
      padding: 5px 5px;
      border-radius: 1.2em;
      transition: all linear .3s;
    }


    #file-library-search-input {
      border-radius: .5em;
    }

    #file-library-search-input:focus {
      border: 2px solid var(--main-color);
    }

    .info-panel-tab-border {
      display: none;
    }
    div#file-library-list-children {
      transition: all linear .3s;
    }

    .file-list-item.active {
      border-top-right-radius: 2.2em;
      border-bottom-right-radius: 2.2em;
      width: fit-content;
      background-color: var(--main-color) !important;
      color: white;
      transition: all linear .3s;
    }

    .outline-item-active {
      border-top-right-radius: 2.2em;
      border-bottom-right-radius: 2.2em;
      width: fit-content;
      background-color: var(--main-color) !important;
      color: white;
      transition: all linear .3s;
    }


    /* theme */
    .theme-preview-div.active, .theme-preview-div.active:hover {
      border-color: var(--main-color);
    }
    #theme-preview-grid {
      max-width: 100% !important;
    }
    #open-theme-folder-btn {
      transition: all .3s;
      border-radius: 2em;
      border: none;
      color: white !important;
      background-color: var(--main-color);
    }
    #open-theme-folder-btn:hover {
      transition: all .3s;
      color: white !important;
      background-color: var(--shadow-color);
    }

    /* export */
    .long-btn {
      transition: all .3s;
      border-radius: 2em;
      border: 2px solid var(--main-color);
      color: var(--main-color);
    }

    .long-btn:hover {
      transition: all .3s;
      color: white !important;
      background-color: var(--main-color);
    }

    .long-btn-wrap {
      padding: 10px;
    }

    .megamenu-section-export {
      font-family: var(--title-font) !important;
    }


    .megamenu-menu-panel h1 {
      padding-bottom: 10px;
      width: fit-content !important;
      border-bottom: var(--main-color) solid 3px;
    }

    .megamenu-menu-panel h2::before {
      content: "H2";
      border-radius: .3em;
      font-size: 25px;
      padding: 3px 7px;
      margin: 5px 15px 5px 1px;
      background-color: var(--main-color);
      color: white;
    }


    /* modal exit dialog */
    .btn-primary {
      transition: all .3 linear;
      border-radius: 1.2em;
      background-color: var(--main-color);
    }

    .btn-default {
      transition: all .3 linear;
      border-radius: 1.2em;
      border: var(--main-color) 3px solid;
      color: var(--main-color);
      background-color: white;
    }

    .btn-primary:hover,
    .btn-default:hover {
      transition: all .3 linear;
      color: white;
      background-color: var(--shadow-color);
    }

    .btn-primary:focus,
    .btn-default:focus {
      transition: all .3 linear;
      color: white;
      background-color: var(--main-color);
    }

    .modal-content {
      border-radius: 1.5em;
      border: none;
    }

    .ImgCaption {
      padding-top: 0;
      margin-top: 0;
      border-bottom: 2px solid var(--shadow-color);
      width: fit-content;
    }

    /* Perference */
    .nav-group-item-item:hover {
      transition: all .3s;
      border: 2px solid var(--main-color);
    }
    .nav-group-item.active {
      color: white;
      font-family: var(--title-font);
      transition: all .3s;
      border-radius: 1.5em;
      padding: 6px 11px 6px 11px;
    }
    .nav-group-item {
      transition: all .3s;
      border-radius: 1.5em;
      width: fit-content;
      cursor: pointer;
    }
    .nav-group-item.active, .nav-group-item:active {
      background-color: var(--main-color) !important;
      color: white !important;
    }
    .pane-group {
      font-family: var(--title-font);
    }

    input:not([type=range]):not([type=color]) {
      outline: none;
      border: 2px solid var(--main-color);
      border-radius: .7em;
      font-size: 16px;
    }

    input:not([type=range]):not([type=color]):focus {
      border-radius: .7em;
      color: white;
      background-color: var(--main-color);
      box-shadow: 0 0 6px 3px var(--shadow-color);
      transition: all .3s linear;
    }

    .pane select,
    .pane .btn {
      border-radius: 0.7em;
      cursor: pointer;
      margin-right: 10px;
    }

    .pane .btn:hover {
      color: white !important;
      transition: all .3s linear;
      background-color: var(--main-color);
    }

    .label-input-group td:hover {
      box-shadow: none;
    }

    .label-input-group .row:hover {
      color: black;
      background-color: white;
    }

    #write.enable-diagrams>[mermaid-type=gantt].md-fences:not(.md-focus) {
      width: inherit !important;
      margin-left: inherit !important;
    }

    /* TODO fix the bug below */
    #footer-word-count-info table, #footer-word-count-info td, #footer-word-count-info tr {
      border: none!important;
      background: inherit !important;
      font-size: 13.5px!important;
      text-align: left!important;
      padding: 0;
      -webkit-user-select: initial;
      user-select: initial;
      margin: 0!important;
      line-height: 1.8;
    }

    """
  end
end
