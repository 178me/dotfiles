import re
import os
import sys
import json
import time
import requests
import pyperclip
import subprocess
from dataclasses import dataclass
from urllib.parse import parse_qs, unquote, urljoin, urlparse
from tqdm import tqdm


@dataclass
class Config:
    lzc_build_yaml: str
    manifest_yaml: str
    changelog: str

    def build(self, output: str = ""):
        try:
            # if "lzc-photo" in os.getcwd():
            #     exec("rm -rf ui/node_modules", True)
            #     exec("cd ui && ni", True)
            cmd = f"lzc-cli project build -f {self.lzc_build_yaml} "
            if output:
                cmd += f"-o {output}"
            exec(cmd, True)
        except:
            exec(f"git restore {self.manifest_yaml}")
            raise Exception("build error")

    def get_version(self):
        with open(self.manifest_yaml, "r") as f:
            contents = f.read()
        match = re.search(VERSION_PATTERN, contents)
        assert match, "未搜索到版本号"
        version = match.group(1)
        return version

    def update_version(self, increment=2):
        with open(self.manifest_yaml, "r") as f:
            contents = f.read()
        match = re.search(VERSION_PATTERN, contents)
        assert match, "未搜索到版本号"
        version = match.group(1)
        new_version = increment_version(version, increment)
        new_contents = re.sub(
            VERSION_PATTERN, f"version: {new_version}", contents)
        with open(self.manifest_yaml, "w") as f:
            f.write(new_contents)


CONFIG_PATH = "./lzc-project.json"
LPK_OUTPUT = "release.lpk"
VERSION_PATTERN = r"version:\s*([0-9]+\.[0-9]+\.[0-9]+)"
HLOGS_PAT = "lzc_pat_2499358d879a2cc04cbe3f18c46eef8e5423998fb74f38ff1843a968603c2bb1"
HLOGS_REQUEST_HEADERS = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "Accept-Language": "zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7",
    "Referer": "https://hlogs.lazycat.cloud/",
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36",
}

group = {
    2: "懒猫官方测试组",
    9000: "系统调试权限组",
    9001: "linakesi 公司内测组",
    9002: "linakesi 公司testing 组",
    9003: "内核测试组",
    9009: "小E调试组",
    9010: "Lzc AI 内测组",
    9011: "相册新数据库",
    9012: "向量数据库",
    9017: "相册测试组1"
}


def check_hlogs_signed_url(url):
    parsed_url = urlparse(url)
    if "cos.accelerate.myqcloud.com" not in parsed_url.netloc:
        return

    query = parse_qs(parsed_url.query, keep_blank_values=True)
    required_params = [
        "q-sign-algorithm",
        "q-ak",
        "q-sign-time",
        "q-key-time",
        "q-signature",
    ]
    missing_params = [name for name in required_params if name not in query]
    if missing_params:
        raise ValueError(
            "签名下载链接参数不完整，请用引号包住整个 URL 后重试，缺少参数: "
            + ", ".join(missing_params)
        )

    sign_time = query["q-sign-time"][0].split(";")
    if len(sign_time) != 2:
        return
    try:
        expire_at = int(sign_time[1])
    except ValueError:
        return
    if time.time() > expire_at:
        expire_at_text = time.strftime(
            "%Y-%m-%d %H:%M:%S", time.localtime(expire_at))
        raise ValueError(f"签名下载链接已过期，过期时间: {expire_at_text}")


def get_hlogs_download_url(log_ref):
    """通过日志服务获取一次性的对象存储下载地址。"""
    api_url = f"https://hlogs.lazycat.cloud/api/v1/download-log/{log_ref}"
    headers = {
        **HLOGS_REQUEST_HEADERS,
        "Authorization": f"Bearer {HLOGS_PAT}",
    }
    response = requests.get(
        api_url,
        headers=headers,
        allow_redirects=False,
        timeout=(10, 30),
    )
    try:
        response.raise_for_status()
        redirect_url = response.headers.get("Location")
        if not redirect_url:
            raise ValueError("日志服务未返回下载重定向地址，请确认会话仍有效")
        download_url = urljoin(api_url, redirect_url)
    finally:
        response.close()

    check_hlogs_signed_url(download_url)
    return download_url


def read_config():
    with open(CONFIG_PATH, "r") as f:
        return Config(**json.load(f))


def find_root(max_levels=3):
    current_dir = os.getcwd()
    levels = 0
    while levels < max_levels:
        if os.path.exists(os.path.join(current_dir, CONFIG_PATH)):
            return current_dir
        parent_dir = os.path.dirname(current_dir)
        if parent_dir == current_dir:
            break
        current_dir = parent_dir
        levels += 1
    return None


def check_health():
    root = find_root()
    assert root, "未检查到项目配置"
    os.chdir(root)


def exec(cmd: str, is_raise=False, text=False):
    print(cmd)
    try:
        if text:
            result = subprocess.run(cmd, shell=True, check=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        else:
            result = subprocess.run(cmd, shell=True, check=True)
        return result.stdout
    except:
        if is_raise:
            sys.exit(1)  # 停止程序的执行


def get_version(config: Config):
    with open(config.manifest_yaml, "r") as f:
        contents = f.read()
    match = re.search(VERSION_PATTERN, contents)
    assert match, "未搜索到版本号"
    version = match.group(1)
    return version


def increment_version(version: str, increment=2):
    version_parts = version.split('.')
    new_parts = int(version_parts[increment]) + 1
    version_parts[increment] = str(new_parts)
    return '.'.join(version_parts)


def edit_changelog():
    """ 更新Changelog """
    check_health()
    config = read_config()
    print("更新最近的commit到changelog")
    version = increment_version(config.get_version())
    exec(f"echo v{version} > temp.txt")
    # exec(
    #     'git log --oneline --format="%s" $(git describe --tags --abbrev=0)..HEAD >> temp.txt'
    # )
    exec(
        'git log --oneline --format="%s" $(git rev-list -n 1 $(git rev-list --tags --grep="appstore" --max-count=1) --grep="appstore")..HEAD >> temp.txt'
    )
    exec(f"cat {config.changelog} >> temp.txt")
    exec(f"cat temp.txt > {config.changelog}")
    exec("rm temp.txt")
    exec(f"sed -i 's/^fix/修复/g' {config.changelog}")
    exec(f"sed -i 's/^feat/新增/g' {config.changelog}")


def publish_current_version_to_store():
    check_health()
    config = read_config()
    print("发布到商店")
    with open(config.changelog, "r") as f:
        if "测试范围" in f.read():
            print("changelog 不标准!")
            return
    if not os.path.exists(LPK_OUTPUT):
        # update_version()
        config.build(LPK_OUTPUT)
    version = config.get_version()
    exec(f"git add {config.manifest_yaml}")
    exec(f"git add {config.changelog}")
    exec(f"git commit -m 'chore: appstore bump version {version}'")
    exec(f"git tag appstore-v{version} -f")
    exec(
        f"lzc-cli appstore publish {LPK_OUTPUT} --clangs zh:{config.changelog}", True)
    pyperclip.copy(f"已发布到懒猫商店: {version}")


def publish_to_testflight(groupId):
    check_health()
    config = read_config()
    groupId = groupId or 2
    print("发布到内测工具")
    config.update_version()
    config.build(LPK_OUTPUT)
    version = config.get_version()
    exec(f"git add {config.manifest_yaml}")
    exec(f"git add {config.changelog}")
    exec(f"git commit -m 'chore: testflight bump version {version}'")
    exec(f"git tag testflight-v{version} -f")
    cmd = f"lzc-cli appstore pre-publish {LPK_OUTPUT} -F {config.changelog}"
    if groupId:
        cmd += f" -G {groupId}"
    exec(cmd, True)
    msg = "已发布到内测工具"
    groupName = group.get(groupId, "")
    if groupName:
        msg += f"[{groupName}]"
    msg += f": {version}"
    pyperclip.copy(msg)


def download_log(log_ref):
    try:
        log_ref = str(log_ref)
        if log_ref.startswith(("http://", "https://")):
            url = log_ref
            check_hlogs_signed_url(url)
        else:
            url = get_hlogs_download_url(log_ref)
        print("下载日志: ", url)
        filename = os.path.basename(unquote(urlparse(url).path)) or f"{log_ref}.zip"
        if not os.path.splitext(filename)[1]:
            filename += ".zip"
        path = os.path.join(os.getcwd(), filename)
        print("开始请求日志文件...")
        request_started_at = time.monotonic()
        response = requests.get(
            url,
            headers=HLOGS_REQUEST_HEADERS,
            stream=True,
            timeout=(10, 300),
        )
        response.raise_for_status()
        headers_elapsed = time.monotonic() - request_started_at
        print(f"收到响应头, 用时 {headers_elapsed:.1f}s")

        total_size = int(response.headers.get("Content-Length", 0)) or None
        chunk_size = 1024 * 512

        with open(path, 'wb') as file, tqdm(
            total=total_size,
            unit='B',
            unit_scale=True,
            unit_divisor=1024,
            desc='下载中',
        ) as progress:
            first_chunk_received = False
            for chunk in response.iter_content(chunk_size=chunk_size):
                if not chunk:
                    continue
                if not first_chunk_received:
                    first_chunk_elapsed = time.monotonic() - request_started_at
                    print(f"开始接收响应体, 首包用时 {first_chunk_elapsed:.1f}s")
                    first_chunk_received = True
                file.write(chunk)
                progress.update(len(chunk))

        print("下载成功")
        os.system(f"zsh -i -c 'x {path}'")
        print(f"解压成功")
        os.remove(path)
        print(f"移除zip")
    except ValueError as e:
        print(f"下载失败: {e}")
    except requests.exceptions.HTTPError as e:
        response = e.response
        print(f"下载失败: HTTP {response.status_code}")
        if response.text:
            print(response.text[:1000])
    except requests.exceptions.RequestException as e:
        print(f"下载失败: {e}")


def build_install(yml_file="", box_name=None):
    originName = None
    if box_name:
        boxList = exec("lzc-cli box list", text=True, is_raise=True)
        if isinstance(boxList, str):
            if box_name in boxList:
                originName = exec("lzc-cli box default", text=True)
                exec(f"lzc-cli box switch {box_name}")
    print(yml_file)
    exec(f"lzc-cli project build -o release.lpk -f {yml_file}", is_raise=True)
    exec(f"lzc-cli app install release.lpk")
    exec(f"rm release.lpk")
    if originName:
        exec(f"lzc-cli box switch {originName}")
