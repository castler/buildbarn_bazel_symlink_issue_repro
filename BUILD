load(":symlink.bzl", "link")
load(":insight.bzl", "insight")

link(
    name = "linked_data",
    srcs = ["//data"],
)

insight(
    name = "foo",
    srcs = [":linked_data"],
)

insight(
    name = "bar",
    srcs = [":linked_data"],
)