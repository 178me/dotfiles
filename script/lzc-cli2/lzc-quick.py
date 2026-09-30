import core
import click


@click.group()
def cli():
    pass


@cli.group()
def d():
    pass


@cli.group()
def p():
    pass


@cli.group()
def e():
    pass


@e.command()
def chg():
    core.edit_changelog()


@p.command()
def appstore():
    core.publish_current_version_to_store()


@p.command()
@click.argument('group_id', type=int)
def testflight(group_id):
    group_id = group_id or 2
    core.publish_to_testflight(group_id)


@d.command()
@click.argument('log_ref', type=str)
def log(log_ref):
    core.download_log(log_ref)


@d.command()
@click.option('--yml', type=str, default="", required=False)
@click.option('--name', type=str, default=None, required=False)
def install(yml, name):
    core.build_install(yml, name)


if __name__ == '__main__':
    cli()
