import AOC

aoc 2024, 19 do
  # @puzzle_towels ~w(r wr b g bwu rb gb br)s |> Enum.sort_by(&String.length/1, :desc)
  @puzzle_towels ~w(guw wg gwuw wwb bbu rug grw gubw buwr rgrbb grwg ubgwgw wug rgrbg wb uwubr uggbubg uuru bwwbgwr brwggrgg urbgrr wrrgu bgr rb rgw rwgw wruub rbrw rrwb brbw gbbr gub bbg uwwgr wbbwwrr rrg rwwu wbwg bb gg rrbbg wgur rgrwru uwgbuw rbu bwg urbuug wrubbb uwrg rrgbwgb wwwwbg wrw bwbb wwr g wggw bwrbg wuwrubu wbrrwgrr uwgguggw bwrw wwrg wbwuurb urg gwrgr gwr rwrrgb wuu gru uwuubgr urwwuuw uub bgw ruwugu wggrwbu ugu uwwguu uugg guu rbuwbgrw brrg rgu bgrgw wwg rgggr bug uww wrrw rbw wwuub ww bg rbbrurg wuw wrrruuwb wbrrbww buwwr urwr wwug rrb wbgg rub bwurw wwwbrr rgr ugrw uuwrg uwrgw rwu grbb gurrgw ggbrrw ubrw ubwrbw w ugrwb wrwu bwrggu uwg wr rrwubu wwubgu wbr wrrrrb ug wrbg wuwb gbrg brg rrbgu bbwr wbb buwu rw bw grrwg brbg wrrwww bgugwr bubw brugugw urgw gwru wrbu r gbgbu wrrr wruwurbu buruur ubg rbbbbb rrw rrrr gugrgb wgbbbww brb gbg rggu gugbrrwu ggu wrg urbw rbr guggg ruugur bbr bgu ubw gbgugb uwrguug wbwwb rwwb uuub rwwwg wbrugrug ggg bub uwr ubugrw urru wgugu ggubuuug bur gwgur urgrubub rgbb ugb rgurru wbwu bgg rwr gggug rur rwrgb uu uwu grb wrguw wuwu rugb rbugb grrug bgwrw buuggru b urwbbrb rbrubr rgb wbbb rrr ruu brbrg uwbwwu brw wbuugwb gbbw gbwu ugr uwb br rr wbw rrrbb gwwrugb uuw wwuuwru grrbg rwwubwb uuurbrw gbu wgrbbwu ggw rwbr urwuu urggw ubrrru gugbgbg rgwb rurw ugrb wwwgr gbbubuu rwbbg bgbruu rwgbu wbgr wrb bubbu urwg urugw rwg wgbbbw gwggggu urb bubb bubruw ruwb bguu wbggb gww rrwgr buuw gbgbgg rru gbrw gwuru wwwwwbr gbru wggrr wwu uug rrwbwg uurw bbgbbb gwu uubg gbb buurrbg www rwwuu ggbbr gbrwugg rgwg wubbu gubbgw ub ggugr bruw bgbbbbb bbrb bwbgrur gr gur ubu rbrb gwbrrb ruwwuuug brr bruu uur bwgb wub bwb bbrgrgwb gwwuw wur wguw gwbugbg gbbbbwr ururb uw urrg uwuw wbg buug wgwbr ruwr ru gbr ruw wgrwr urr ugbwuwgw bggrgw wru ggurbw brguwrru gbwb rwubr grurgr gwruu rrgg wuwg rg rrwbb ubbrwg rbg bwr ggr gwbwu wuurrw wbbburgg brgbgb bgrwg urgb wuubb ugg wbrgwu rbuurbuw wgr rgrr grrwuw uugu grg rbrrwbww burgg ubrur gwwgug wrwgbru rbgr gbw bgbbb wgb bgwub guubrg uru ubgr uuggg rwb bwbg bwu gug uugrugw rgww wbbgrr bgwwurw wgu bubu wrwwrw uuwgbw rrrwu ruuwww bu wu rbggbg bbubrrw urwgww rrgwr guwgrrwg bbb gwg rwwg gguu bwgwrg wruu grbw wwgb buurw wgw gwb wbugu urwu ggb buuuw wbggr wgwgw ubr ggur bgb brggr bwbrr bbbubw uuu grgb wgwww buggrrg grr ggurbu wbu rggbbur buu brgrgbg guurgwbb brubru bwuub rbrru gwgwb gb wruw bww buw wrr ubgg rrugu rbb gwrw wbwbbwb ugw ubb bwwuu gw bru bugwr wwburw gwwr wrugrugw brrwbw)s
                 |> Enum.sort_by(&String.length/1, :desc)

  def p1(input) do
    input
    |> String.split("\n")
    |> Enum.drop(2)
    |> Enum.filter(&match_towels?/1)
    |> Enum.count()
  end

  def p2(_input) do
  end

  def match_towels?(""), do: true

  for pattern <- @puzzle_towels do
    def match_towels?(unquote(pattern) <> rest), do: match_towels?(rest)
  end

  def match_towels?(_), do: false
end
