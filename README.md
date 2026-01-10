# Mewduct

![Mewduct Logo](doc/img/mewduct-logo.png)

Video streaming CMS without a server-side application

## Description

Mewduct implements a video streaming site using only a client-side application and static files served by a web server.  
Since all you need to do is place the generated files on the server, no server-side application is required. Video processing is performed locally, allowing server resource usage to remain extremely low.

Mewduct is designed for people who don't want to use existing video platforms (e.g., YouTube, Vimeo) but also don't want to operate high‑performance and expensive servers capable of handling video encoding.

The structure of the files required for distribution is generated through command‑line scripts.  
Some settings (such as video titles and descriptions) are not provided through these scripts and must be edited directly in the generated files.

The role of the command‑line scripts is simply to place the files used for video distribution in the correct locations.

Mewduct supports multiple users, but because commands must be executed when uploading videos, it does not provide features suitable for multi‑user video uploads.
However, implementing a hook to run commands upon upload is straightforward.

Mewduct does not require viewer accounts.  
Because of this, you cannot restrict videos to specific audiences.  
However, you *can* mark videos as unlisted, meaning they will not appear on the home page or user pages.

## Division of Work Between Local and Server

Ultimately, the files for distribution must be placed on the server, but there are several ways to divide the workflow between local and server environments.

### Encoding on the server

Upload the source video to the server and run `mewduct-encode.zsh` and `mewduct-import.zsh` on the server.

### Importing on the server

Run `mewduct-encode.zsh` locally, upload the `videoout` directory to the server, and run `mewduct-import.zsh` on the server.

This is the most standard workflow.

### Mounting the server filesystem and importing locally

Mount the server's webroot using SSHFS or similar, then run `mewduct-encode.zsh` and `mewduct-import.zsh` locally.

Recommended when you are the only user.

### Configuring locally and mirroring to the server

Run `mewduct-encode.zsh` and `mewduct-import.zsh` locally, then sync your updated local webroot to the server using `rsync` or similar.

This method is intended for single‑user setups.

## Installation

1. Place the files under `webroot/` into your web server's public root (e.g., `/srv/http/`).
2. Edit the deployed `config.js`.

## Updating

1. `git pull`
2. `rsync -rvu --exclude config.js webroot/ /path/to/webroot/`

## Server Configuration

Mewduct uses URLs like `/play.html/${user_id}/${media_id}`.  
Your server must be configured so that `play.html` is served for such URLs.

### Nginx

```
server {
    # ...

    root /path/to/webroot;

    location /user.html/ {
        try_files /user.html =404;
    }

    location /play.html/ {
        try_files /play.html =404;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Caddy

```
example.com {
    root * /path/to/webroot
    file_server

    rewrite /user.html/* /user.html
    rewrite /play.html/* /play.html
    
    try_files {path} /index.html
}
```

### Lighttpd

```
server.modules += ( "mod_rewrite" )

url.rewrite-once = (
    "^/user\.html/.*" => "/user.html",
    "^/play\.html/.*" => "/play.html",
)
```

### Apache

```
<FilesMatch "^(user|play)\.html$">
    AcceptPathInfo On
</FilesMatch>
```

## Importing and Updating Videos

### Generating a new video

Prepare the video you want to upload, then convert it into a Mewduct‑compatible format containing multiple resolutions.

```
mewduct-encode.zsh <source_video> [<output_directory>]
```

If the output directory is omitted, files are placed in `./videoout`.

`mewduct-encode.zsh` converts only the resolutions that are feasible using `ffmpeg`.  
Typically, lower resolutions use MPEG4 baseline, while HD and above use VP9.

It also generates `thumbnail.webp` (used as the thumbnail) and `titlemeta.yaml` (for manually writing metadata).  
Before importing, update `titlemeta.yaml`, and replace `thumbnail.webp` if you want a custom thumbnail.

### Importing a video

```
mewduct-import.zsh <webroot> <user_id> <video_directory>
```

In Mewduct, “importing a video” means generating a `media_id` and moving the source video directory into `user/$user/$media_id`.

`mewduct-import.zsh` automatically calls `mewduct-update.rb`, `mewduct-user.rb update`, and `mewduct-home.rb`.

After import, the script outputs the path `$user/$media_id`.  
You usually don't need this, but it's useful when updating metadata later.

If you've named your videos appropriately, you can also locate them later by searching `/media/$user/*/titlemeta.yaml`.

### Updating a video

```
mewduct-update.rb <webroot_dir> <user_id> <media_id>
```

Updating a video means updating metadata or reflecting newly added resolutions.  
If this is the first update, it also generates the required metadata JSON.

Replacing existing video files or subtitle files is automatically reflected without running an update.

Subtitle files named `captions.<langcode>.vtt` are imported as subtitles during update.

## Updating Video Information

Video information is edited in `titlemeta.yaml`.  
Run `mewduct-update.rb` to apply the changes.

- `title`: the video title  
- `description`: the video description  
- `unlisted`: if `true`, the video will not appear on the home page or user pages (similar to YouTube's unlisted videos)

## Updating User Pages

```
mewduct-user.rb update <webroot_directory> <user_id>
```

This updates the user page, specifically `usermeta.json` and `videos.json`.

Since the home page's video list is built from each user's `videos.json`, you must update the user page before updating the home page.

## Updating the Home Page

```
mewduct-home.rb <webroot_directory>
```

Updates the home page's video list and user list.

Because Mewduct does not require viewer login, there is no per‑user home page.  
This updates the single global home page.

## User Operations

User operations are handled via subcommands of `mewduct-user.rb`.

Except for `update`, these commands are interactive utilities.  
When integrating with other programs, direct file manipulation is recommended.

```
mewduct-user.rb <action> <webroot_directory> <user_id>
```

### create

Creates a user with the specified `user_id`.

Prompts interactively for the username (display name).

### edit

Edits user information.

A YAML file containing editable fields opens in `$EDITOR`.  
Changes are applied when saved.

## Customization

### Editing parameters

Parameters such as resolution candidates or the threshold for switching to VP8 are embedded in the scripts.

If these parameters or behaviors don't suit your needs, modifying the scripts is recommended.

Files named `*.local` or `*.local.*` are ignored by `.gitignore`, allowing you to maintain custom scripts without conflicts during repository updates.

## 👍 Reactions

Although Mewduct does not include a reaction feature by default, setting `reaction_post_to` in `config.js` enables it.

A server‑side application to receive reactions is not included in Mewduct.

Setting `reaction_get_from` allows displaying reaction counts.

A server‑side application to return reaction counts is also not included.

## Comments

Mewduct does not include a comment system, but you can embed HTML into the player view by writing HTML strings into `player_additional_1` and `player_additional_2`.  
These are inserted as the `innerHTML` of additional `section` elements in the player.

You can use this mechanism to implement a comment feature.
