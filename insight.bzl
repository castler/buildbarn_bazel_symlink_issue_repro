def _impl(ctx):
    out = ctx.actions.declare_file(ctx.attr.name)

    ctx.actions.run_shell(
        outputs = [out],
        inputs = ctx.files.srcs,
        command = "true; ls -lR > '%s'" % (out.path),
    )

    return [DefaultInfo(files = depset([out]))]

insight = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    },
)
