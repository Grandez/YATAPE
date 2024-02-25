list_merge_list = function(...) { rlist::list.merge(...) }
list_merge = function(lst1, lst2) {
    if (is.null(lst1) || length(lst1) == 0) return (lst2)
    if (is.null(lst2) || length(lst2) == 0) return (lst1)
    rlist::list.merge(lst1, lst2)
}
list_clean = function(data,fun=is.null,recursive=FALSE) {
   rlist::list.clean(data, fun, recursive)
}
list_append_list = function(...) { rlist::list.append(...) }
list_append = function(lst1, lst2) {
   if (is.null(lst1) || length(lst1) == 0) return (lst2)
   if (is.null(lst2) || length(lst2) == 0) return (lst1)
   rlist::list.append(lst1, lst2)
}
list_combine = function(lst1, lst2) {
   # Dadas dos listas con nombre
   # combina los elementos
   if (is.null(lst1) || length(lst1) == 0) return (lst2)
   if (is.null(lst2) || length(lst2) == 0) return (lst1)

   names1 = sort(names(lst1))
   names2 = sort(names(lst2))

   res = list()
   idx1 = 1
   idx2 = 2
   while (idx1 <= length(lst1) && idx2 <= length(lst2)) {
       if (names1[idx1] < names[idx2]) {
           res[names(lst1)[idx1]] = lst1[[idx1]]
           idx1 = idx1 + 1
       }
       if (names1[idx1] == names[idx2]) {
           lst = rlist::list.merge(lst1[[idx1]], lst1[[idx2]])
           res[names(lst1)[idx1]] = lst
           idx1 = idx1 + 1
           idx2 = idx2 + 1
       }
       if (names1[idx1] > names[idx2]) {
           res[names(lst2)[idx2]] = lst2[[idx2]]
           idx2 = idx2 + 1
       }
   }
   if (idx1 < length(lst1)) res = rlist::list.merge(res, lst1[[idx1:length(lst1)]])
   if (idx2 < length(lst2)) res = rlist::list.merge(res, lst2[[idx2:length(lst2)]])
   res
}
