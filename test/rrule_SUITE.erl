-module(rrule_SUITE).

-compile(export_all).

-include("ct.hrl").

all() -> [satisfy, in_range, merge_datetimes].

%%%%%%%%%%%%%%%%
%% test cases %%
%%%%%%%%%%%%%%%%


merge_datetimes(_Config) ->
		D1 = {{2009, 04, 12}, {0, 0, 0}},
		D2 = {{2009, 06, 12}, {0, 0, 0}},
		D3 = {{2009, 05, 12}, {0, 0, 0}},
		D4 = {{2009, 07, 12}, {0, 0, 0}},
		D5 = {{2009, 08, 12}, {0, 0, 0}},
		D6 = {{2009, 09, 12}, {0, 0, 0}},
		DTs = [{D1, D2}, {D5, D6}, {D3, D4}],

		[{{{2009,5,12},{0,0,0}},{{2009,7,12},{0,0,0}}},
		 {{{2009,8,12},{0,0,0}},{{2009,9,12},{0,0,0}}},
		 {{{2009,4,12},{0,0,0}},{{2009,6,12},{0,0,0}}},
		 {{{2009,4,12},{0,0,0}},{{2009,7,12},{0,0,0}}}] = rrule:merge_datetimes(DTs).

satisfy(_Config) ->

	[[{{{2009,5,7},{22,15,0}},{{2009,5,7},{23,59,59}}}],
	 [{{{2009,5,14},{22,15,0}},{{2009,5,14},{23,59,59}}}],
	 [{{{2009,5,21},{22,15,0}},{{2009,5,21},{23,59,59}}}],
	 [{{{2009,5,28},{22,15,0}},{{2009,5,28},{23,59,59}}}],
	 [{{{2009,6,4},{22,15,0}},{{2009,6,4},{23,59,59}}}],
	 [{{{2009,6,11},{22,15,0}},{{2009,6,11},{23,59,59}}}],
	 [{{{2009,6,18},{22,15,0}},{{2009,6,18},{23,59,59}}}],
	 [[]]] = rrule:satisfy({[{weekday, thursday}, {time, {22, 15}}], 3*3600}, {{2009, 05, 7}, {8, 4, 6}}, {{2009, 06, 25}, {9, 12, 43}}),

	[{{{2009,6,11},{0,0,0}},{{2009,6,11},{23,59,59}}},
	{{{2009,6,18},{0,0,0}},{{2009,6,18},{23,59,59}}}] = rrule:satisfy({[{weekday, thursday}], 3*3600}, {{2009, 06, 8}, {8, 4, 6}}, {{2009, 06, 24}, {9, 12, 43}}).


in_range(_Config) ->
	R1 = {[{weekday, thursday}, {time,22}], 3*3600},
	R2 = {[{weekday, thursday}, {time,21}], 3*3600},
	false = rrule:in_range([R1,R2], {{{2009, 06, 25}, {20, 4, 6}}, {{2009, 06,25}, {23, 12, 43}}}),
	true  = rrule:in_range([R1,R2], {{{2009, 06, 25}, {22, 4, 6}}, {{2009, 06,25}, {23, 12, 43}}}).
