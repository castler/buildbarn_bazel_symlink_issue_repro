
def _link_impl(ctx):
    out_files = list()

    for src in ctx.files.srcs:
        out = ctx.actions.declare_file(src.basename)
        ctx.actions.symlink(
            output = out,
            target_file = src,
            progress_message = "Symlinking {}".format(src.basename),
        )
        out_files.append(out)

    
    return DefaultInfo(
        files = depset(direct = out_files),
    )

link = rule(
    implementation = _link_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
        ),
    },
)
