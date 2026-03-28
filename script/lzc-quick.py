import os
import click
import requests


@click.group()
def cli():
    pass


@cli.group()
def d():
    """Subcommand d help"""
    pass


@cli.group()
def p():
    """Subcommand d help"""
    pass


@p.command()
@click.argument('group_id', type=int)
def testflight(group_id):
    
    group_id = group_id or 2
    # update_version()
    # build(LPK_OUTPUT)
    # version = get_version()


@d.command()
@click.argument('log_id', type=int)
def log(log_id):
    """Subcommand log help"""
    click.echo(f'Log ID: {log_id}')
    try:
        url = f"https://hlogs.lazycat.cloud/api/v1/download-log/{log_id}"
        h = {
            "Authorization": "Basic bG5rczpza25s",
            "Cookie": "userToken=e473a5ad1e794387a82e9fabd3d9d087"
        }
        # 发送 GET 请求
        response = requests.get(url, headers=h)
        response.raise_for_status()  # 检查请求是否成功
        # 将内容写入文件
        path = os.path.join(os.getcwd(), f"{log_id}.zip")
        with open(path, 'wb') as file:
            file.write(response.content)
        print(f"下载成功")
        os.system(f"zsh -i -c 'x {path}'")
        print(f"解压成功")
        os.remove(path)
        print(f"移除zip")
    except requests.exceptions.RequestException as e:
        print(f"下载失败: {e}")


if __name__ == '__main__':
    cli()
