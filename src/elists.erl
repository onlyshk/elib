%% ``The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved via the world wide web at http://www.erlang.org/.
%% 
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% All Rights Reserved.''
%%
%% @author Jacob Perkins

%% @doc Extra lists functions.

-module(elists).

-export([first/2, get_value/2, get_value/3, prepend/2,
		 mapfilter/2, mapfilter_chain/2, propmerge/3,
		 sort_chain_generator/1, splitmany/2, sublist/3, union/2]).

%% @doc Return the first element where F returns true, or none.
first(F, List) ->
	case lists:dropwhile(fun(Elem) -> not F(Elem) end, List) of
		[First | _] -> First;
		[] -> none
	end.

get_value(Key, List) -> get_value(Key, List, undefined).

%% @doc This function provides same functionality as proplists:get_value, but uses
%% lists:keyfind, and assumes the list is of 2-tuples. Apparently lists:keyfind
%% is much faster than proplists:get_value.
get_value(Key, List, Default) ->
	case lists:keyfind(Key, 1, List) of
		{Key, Val} -> Val;
		false -> Default
	end.

%% @equiv [Elem | List]
prepend(Elem, List) -> [Elem | List].

%% @doc Combines map and filter into 1 operation. Like map, calls F on each
%% item in List. But if F returns false, then the result is dropped.
%% @spec mapfilter(F::function(), List::list()) -> list()
mapfilter(F, List) -> lists:reverse(mapfilter(F, List, [])).

mapfilter(_, [], Results) ->
	Results;
mapfilter(F, [Item | Rest], Results) ->
	case F(Item) of
		false -> mapfilter(F, Rest, Results);
		Term -> mapfilter(F, Rest, [Term | Results])
	end.

mapfilter_chain([], Item) ->
	Item;
mapfilter_chain([F | Rest], Item) ->
	case F(Item) of
		false -> false;
		Item2 -> mapfilter_chain(Rest, Item2)
	end.

%% @doc Merge 2 proplists. F is called for any value that does not compare
%% equal, and should return the value to keep. This is a convience wrapper
%% around dict:merge/3.
propmerge(F, L1, L2) ->
	dict:to_list(dict:merge(F, dict:from_list(L1), dict:from_list(L2))).

sort_chain_generator(SortFuns) -> fun(A, B) -> sort_chain(SortFuns, A, B) end.

sort_chain([], _, _) ->
	true;
sort_chain([F | Rest], A, B) ->
	case F(A, B) of
		true -> true;
		false -> false;
		undefined -> sort_chain(Rest, A, B)
	end.

%% @doc Split `List' into many lists, each with `N' elements. The last list
%% may contain less than `N' elements.
%% @spec splitmany(N::integer(), List::list()) -> [list()]
splitmany(N, List) -> lists:reverse(splitmany(N, List, [])).

splitmany(_, [], Split) ->
	Split;
splitmany(N, List, Split) when length(List) < N ->
	[List | Split];
splitmany(N, List, Split) ->
	{Part, Rest} = lists:split(N, List),
	splitmany(N, Rest, [Part | Split]).

sublist(L, Start, _) when length(L) < Start -> [];
sublist(L, Start, Limit) -> lists:sublist(L, Start, Limit).

union(L1, L2) -> sets:to_list(sets:union(sets:from_list(L1), sets:from_list(L2))).