locals_without_parens = ~w[
  html htm
  head title style script
  noscript template
  body section nav article aside h1 h2 h3 h4 h5 h6
  header footer address main
  p pre blockquote ol ul li dl dt dd figure figcaption div
  a em strong small s cite q dfn abbr data time code var samp kbd
  sub sup i b u mark ruby rt rp bdi bdo span
  ins del
  iframe object video audio canvas
  map svg math
  table caption colgroup tbody thead tfoot tr td th
  form fieldset legend label button select datalist optgroup
  option text_area output progress meter
  details summary menuitem menu
  meta link base
  area br col embed hr img input keygen param source track wbr
  text partial

  form_for inputs_for
  checkbox color_input checkbox color_input date_input date_select datetime_local_input
  datetime_select email_input file_input hidden_input number_input password_input range_input
  search_input telephone_input textarea text_input time_input time_select url_input
  reset submit phx_label multiple_select select phx_link phx_button
]a |> Enum.map(fn e -> {e, :*} end)

[
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
