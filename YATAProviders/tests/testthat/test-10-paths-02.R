context("Making Paths")


tst = FACT$get("TST", "Test")

# test_that("Invalid Pairs", {
#    expect_error(tst$getPath("AAA","000"))
#    expect_error(tst$getPath("000","AAA"))
#    expect_error(tst$getPath("111","000"))
# })
#
# NNN/MMM/NRM > MMM/NNN - Nada mas
# test_that("Pair direct", {
#     path = tst$getLatests("MMM","NNN")
#     expect_true(length(path) ==     1, label ="Par directo")
    # expect_true(path[1]      == "NNN", label ="Par directo")
    # expect_true(path[2]      == "MMM", label ="Par directo")
#})
#
# NNN/MMM/INV -> MMM/NNN -> INV
# test_that("Pair inverse", {
#     path = tst$getLatests("NNN","MMM")
#     expect_true(length(path) ==     3, label ="Par inverso")
#     expect_true(path[1]      == "NNN", label ="Par inverso 1")
#     expect_true(path[2]      == "MMM", label ="Par inverso 2")
#     expect_true(path[3]      == "INV", label ="Par inverso 3")
#})

# No hay camino
# test_that("No Path from Left 1", {
#     path = tst$getPath("MMM","PPP")
#      expect_true(length(path) > 0    , label = "Pa1r level 1")
#     expect_true(path[1]      == "XXX", label = "Pa1r level 1")
#     expect_true(path[2]      == "BBB", label = "Pa1r level 1")
#     expect_true(path[3]      == "AAA", label = "Pa1r level 1")
#})

# No hay camino inverso
# test_that("No path from right 1", {
#     path = tst$getPath("NNN","PPP")
#      expect_true(length(path) > 0    , label = "Pa1r level 1")
#     expect_true(path[1]      == "XXX", label = "Pa1r level 1")
#     expect_true(path[2]      == "BBB", label = "Pa1r level 1")
#     expect_true(path[3]      == "AAA", label = "Pa1r level 1")
#})

# XXX/BBB/A# AA -> BBB/XXX -> AAA/BBB#
test_that("Pair level 2", {
    path = tst$getLatests("000","999")
    expect_true(length(path) > 0    , label = "Pa1r level 1")
#     expect_true(path[1]      == "XXX", label = "Pa1r level 1")
#     expect_true(path[2]      == "BBB", label = "Pa1r level 1")
#     expect_true(path[3]      == "AAA", label = "Pa1r level 1")
})

# test_that("Pair level 2 - 1L INV", {
#     path = tst$getPath("222","999")
#     expect_true(length(path) > 0    , label = "Pa1r level 2")
# #     # expect_true(path[1]      == "ZZZ", label = "Pa1r level 2")
# #     # expect_true(path[2]      == "YYY", label = "Pa1r level 2")
# #     # expect_true(path[3]      == "CCC", label = "Pa1r level 2")
# #     # expect_true(path[4]      == "AAA", label = "Pa1r level 2")
#})

# test_that("Pair level 2 - 1R INV", {
#     path = tst$getPath("000","888")
#     expect_true(length(path) > 0    , label = "Pa1r level 2")
# #     # expect_true(path[1]      == "ZZZ", label = "Pa1r level 2")
# #     # expect_true(path[2]      == "YYY", label = "Pa1r level 2")
# #     # expect_true(path[3]      == "CCC", label = "Pa1r level 2")
# #     # expect_true(path[4]      == "AAA", label = "Pa1r level 2")
#})

# test_that("Pair level 4", {
#     path = tst$getPath("AAA","III")
#     expect_true(length(path) > 0    , label = "Pa1r level 2")
# #     # expect_true(path[1]      == "ZZZ", label = "Pa1r level 2")
# #     # expect_true(path[2]      == "YYY", label = "Pa1r level 2")
# #     # expect_true(path[3]      == "CCC", label = "Pa1r level 2")
# #     # expect_true(path[4]      == "AAA", label = "Pa1r level 2")
# })

# test_that("Pair level 4", {
#     path = tst$getPath("AAA","RRR")
#     expect_true(length(path) > 0    , label = "Pa1r level 2")
#     # expect_true(path[1]      == "ZZZ", label = "Pa1r level 2")
#     # expect_true(path[2]      == "YYY", label = "Pa1r level 2")
#     # expect_true(path[3]      == "CCC", label = "Pa1r level 2")
#     # expect_true(path[4]      == "AAA", label = "Pa1r level 2")
#})

# test_that("Cameras new", {
#    data = list(
#       id = "TEST2"
#       ,name = "TEST Other camera"
#    )
#    cameras$add(data)
#    expect_equal(nrow(cameras$getActiveCameras()), 2)
#    expect_equal(nrow(cameras$getInactiveCameras()), 1)
#    expect_equal(nrow(cameras$getAllCameras()), 3)
# })
#
# test_that("Cameras new inactive", {
#    data = list(
#       id = "TEST3"
#       ,name = "TEST Other camera2"
#       ,active = 0
#    )
#    cameras$add(data)
#    expect_equal(nrow(cameras$getActiveCameras()), 2)
#    expect_equal(nrow(cameras$getInactiveCameras()), 2)
#    expect_equal(nrow(cameras$getAllCameras()), 4)
# })
#
# test_that("Switch status 1", {
#    cameras$select(id="TEST3")
#    cameras$switchStatus(isolated=TRUE)
#    expect_equal(nrow(cameras$getActiveCameras()), 3)
#    expect_equal(nrow(cameras$getInactiveCameras()), 1)
#    expect_equal(nrow(cameras$getAllCameras()), 4)
# })
#
# test_that("Switch status 2", {
#    cameras$switchStatus("TEST3", isolated=TRUE)
#    expect_equal(nrow(cameras$getActiveCameras()), 2)
#    expect_equal(nrow(cameras$getInactiveCameras()), 2)
#    expect_equal(nrow(cameras$getAllCameras()), 4)
# })
#
