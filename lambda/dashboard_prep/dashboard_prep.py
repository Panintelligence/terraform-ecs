import logging
import shutil
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(event)
    try:
        # Remove and recreate "keys" directory
        if os.path.isdir("/mnt/efs/keys"):
            shutil.rmtree("/mnt/efs/keys")
        os.makedirs("/mnt/efs/keys")

        # Remove and recreate "files" directory
        if os.path.isdir("/mnt/efs/files"):
            shutil.rmtree("/mnt/efs/files")
        os.makedirs("/mnt/efs/files")

        # Copy "themes" directory if not exist or FORCE_THEMES is true
        if not os.path.isdir("/mnt/efs/themes") or os.getenv("FORCE_THEMES") == "true":
            shutil.copytree("themes", "/mnt/efs/themes")
        elif os.getenv("FORCE_THEMES") == "true":
            shutil.rmtree("/mnt/efs/themes")
            shutil.copytree("themes", "/mnt/efs/themes")

        # Copy "locale" directory if not exist or FORCE_LOCALE is true
        if not os.path.isdir("/mnt/efs/locale") or os.getenv("FORCE_LOCALE") == "true":
            shutil.rmtree("/mnt/efs/locale", ignore_errors=True)  # Remove existing locale directory
            shutil.copytree("locale", "/mnt/efs/locale")  # Copy locale directory

        # Check if locale files exist
        locale_files = os.listdir("/mnt/efs/locale")
        if locale_files:
            logger.info(f"Locale files exist in /mnt/efs/locale: {locale_files}")
        else:
            logger.warning("No locale files found in /mnt/efs/locale")

        # Remove and recreate "svg", "custom_jdbc", and "images" directories
        for directory in ["svg", "custom_jdbc", 'images']:
            if os.path.isdir(f"/mnt/efs/{directory}"):
                shutil.rmtree(f"/mnt/efs/{directory}")
            os.makedirs(f"/mnt/efs/{directory}")

        # Log all directories in "/mnt/efs/"
        directories = os.listdir("/mnt/efs/")
        logger.info(f"Directories in /mnt/efs/: {directories}")
    except Exception as e:
        logger.error(e)
        raise e