# Keywords Cloud API

## Routes
### Authenticate Routes

#### Overview

| Method |            URL                |        What to do        |
| :----: | :------------------------:    | :----------------------: |
|  POST  | /api/v1/accounts/authenticate | login and get auth token |

#### Example

**POST /api/v1/accounts/authenticate**
```shell
$ curl http://localhost:9292/api/v1/accounts/authenticate \
	-X POST \
	-H 'content-type: application/json' \
	-d '{
          "account": "a1234@mail.com",
          "password": "a1234"
        }'
```

```
{
  "uid":1,
  "auth_token": "eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIiwiZXhwIjoxNDY4MDYwNjI5fQ..B8PisW3mwnS51goa.Lz87.v_ydEDJ9ypa2kiiUbe"
}
```

### Account Routes
#### Overview

| Method | URL                     | What to do                               | success |
| ------ | ----------------------- | ---------------------------------------- | ------- |
| GET    | /api/v1/accounts/{uid}  | get all courses about a certain account  | 200     |
| GET    | /api/v1/accounts/{uid}/{cid}  | get course name  | 200     |

#### Example

**GET /api/v1/accounts/:uid**

```shell
curl http://localhost:9292/api/v1/accounts/1 \
	-H 'content-type: application/json' \
	-H 'authorization: bearer {auth_token}'
```

```
{
  "data": [
    {
      "cid": 1,
      "name": "健康與人生"
    },
    {
      "cid": 2,
      "name": "作業系統 Operating Systems"
    },
    {
      "cid": 3,
      "name": "美容美髮"
    }
  ]
}
```

**GET /api/v1/accounts/:uid/:cid**

```shell
curl http://localhost:9292/api/v1/accounts/1/1 \
	-H 'content-type: application/json' \
	-H 'authorization: bearer {auth_token}'
```

```
{
  "data": "健康與人生"
}
```

### Folder Routes
#### Overview

| Method  | URL                                           | What to do                                     |
| ------  | ----------------------------------------------| ---------------------------------------------- |
| GET    | /api/v1/accounts/{uid}/{course_id}/{folder_type}/  | folder of this course (folder type : subtitles or slides or concepts) |
| POST    | /api/v1/accounts/{uid}/{course_id}/{folder_type}/  | create new folder(slide or subtitle or concepts) for the course |

#### Example

**GET /api/v1/accounts/:uid/:course_id/:folder_type**

```shell
curl http://localhost:9292/api/v1/accounts/1/1/subtitles \
	-H 'content-type: application/json' \
	-H 'authorization: bearer {auth_token}'
```

```
{
  "data": [
    {
      "id": 1,
      "data": {
        "course_id": 1,
        "folder_type": "subtitle",
				"chapter_order": 1,
        "chapter_id": 1,
        "name": "物聯網概論課程簡介",
        "folder_url_encrypted": "rByi76KgcTSQa1OzPbVnCIeaiqlKda5yimKKtkOHPQ0I1F1un8f8h1PmT62WZb0e57Gr"
      }
    },
    {
      "id": 2,
      "data": {
        "course_id": 1,
        "folder_type": "subtitle",
        "chapter_order": 2,
				"chapter_id": 2,
        "name": "第 1週: 物聯網基礎架構與應用簡介",
        "folder_url_encrypted": "KV2xfxPk1IWwYlXWDaDPWRUq490DVIUNiLFP23nV5n3mOyefBwY3KBIxJdAr0iZUnFt2"
      }
    }
	]
}
```

**POST /api/v1/accounts/:uid/:course_id/:folder_type**

```shell
$ curl http://localhost:9292/api/v1/accounts/1/1/folders/ \
 	-X POST \
	-H 'content-type: application/json' \
	-H 'authorization: bearer {auth_token}' \
	-d '{
    "folder_url": "XXXXXXXXOOOOOOOO",
		"folder_type": "subtitle"
	}'
```

```
[
  {
    "type": "folder",
    "id": 1,
    "attributes": {
      "folder_type": "subtitle",
      "course_id": 1,
			"chapter_id":1,
      "chapter_order": 1,
      "name": "物聯網概論課程簡介",
      "folder_url": "XXXXXXXXOOOOOOOO"
    }
  },
  {
    "type": "folder",
    "id": 2,
    "attributes": {
      "folder_type": "subtitle",
      "course_id": 1,
			"chapter_id":2,
      "chapter_order": 2,
      "name": "第 1週: 物聯網基礎架構與應用簡介",
      "folder_url": "XXXXXXXXOOOOOOOO"
    }
  },
  {
    "type": "folder",
    "id": 3,
    "attributes": {
      "folder_type": "subtitle",
      "course_id": 1,
			"chapter_id":3,
      "chapter_order": 3,
      "name": "第 2週: 感知層/網路層/應用層技術  ",
      "folder_url": "XXXXXXXXOOOOOOOO"
    }
  }
]
```

### File Routes
#### Overview

| Method  | URL                                           | What to do                                     |
| ------  | ----------------------------------------------| ---------------------------------------------- |
| GET     | /api/v1/accounts/{uid}/{course_id}/folders/{folder_id}  |  file of this course |
| POST    | /api/v1/accounts/{uid}/{course_id}/folders/{folder_id}/files/  | create new file for folder |
| POST    | /api/v1/accounts/{uid}/{course_id}/folders/{folder_id}/  | create video url for chapter |
| DELETE    | /api/v1/accounts/{uid}/{course_id}/folders/{folder_id}/files/  | delete a certain file |

#### Example

**GET /api/v1/accounts/:uid/:course_id/folders/:folder_id**

```shell
curl http://localhost:9292/api/v1/accounts/1/1/folders/3 \
	-H 'content-type: application/json' \
	-H 'authorization: bearer {auth_token}'
```

```
{
  "data": [
    {
      "id": "4cddac19-0c7d-49e7-a553-2c454ed43546",
      "data": {
        "filename": "1.txt",
        "document_encrypted": "yyOVPRH82gXr6AKGT6mns4L/vjjuyu3Brcw0e9nemzqELOIZJOFEMJ+hAPfxqtwcBcqmGg==",
        "checksum": null
      }
    },
    {
      "id": "1de7c7c5-9833-47fd-af03-5d167ffd0d78",
      "data": {
        "filename": "1.txt",
        "document_encrypted": "uYBs1efbV4FfVHi5iDBeoITFI0Z/AWqLVz8vAnpyzmR3SBhHouaC4cqUmq9m6PPvGuCz7Q==",
        "checksum": null
      }
    }
  ]
}
```

**POST /api/v1/accounts/:uid/:course_id/folders/:folder_id/files/**

```shell
$ curl http://localhost:9292/api/v1/accounts/1/1/folders/3/files/ \
 	-X POST \
	-H 'content-type: application/json' \
	-H 'authorization: bearer {auth_token}' \
	-d '{
    "filename": "1.txt",
		"document": "XXXXXXXXOOOOOOOO"
	}'
```

```
{
  "type": "files",
  "id": "978e09d4-5eb4-4b1c-a4a1-37cd6fbd6aa0",
  "data": {
    "folder_id": 3,
    "filename": "1.txt",
    "checksum": null,
    "document_base64": "MTExMTExMTExMTEx",
    "document": "111111111111"
  }
}
```

**POST /api/v1/accounts/:uid/:course_id/folders/:folder_id/**

```shell
$ curl http://localhost:9292/api/v1/accounts/1/1/folders/3 \
 	-X POST \
	-H 'content-type: application/json' \
	-H 'authorization: bearer {auth_token}' \
```

```
[
  {
    "type": "url",
    "id": 1,
    "attributes": {
      "course_id": 1,
      "chapter_id": 1,
      "chapter_order": 1,
      "video_id": 1,
      "video_order": 1,
      "name": "網路安全課程大綱",
      "video_url": "https://youtu.be/NHAEbzvptfU"
    }
  },
  {
    "type": "url",
    "id": 2,
    "attributes": {
      "course_id": 1,
      "chapter_id": 1,
      "chapter_order": 1,
      "video_id": 2,
      "video_order": 2,
      "name": "網路安全簡介",
      "video_url": "https://www.youtube.com/watch?v=Awux7yIScDg；http://v.youku.com/v_show/id_XOTY1NDIxNTUy.html"
    }
  },
  {
    "type": "url",
    "id": 3,
    "attributes": {
      "course_id": 1,
      "chapter_id": 1,
      "chapter_order": 1,
      "video_id": 2,
      "video_order": 2,
      "name": "網路攻擊工具",
      "video_url": "https://www.youtube.com/watch?v=cD1EvPsSej0；http://v.youku.com/v_show/id_XOTY1NDIyMjk2.html"
    }
  }
]
```

**DELETE /api/v1/accounts/:uid/:course_id/folders/:folder_id/files/**

```shell
$ curl http://localhost:9292/api/v1/accounts/1/1/folders/3/files/ \
 	-X DELETE \
	-H 'content-type: application/json' \
	-H 'authorization: bearer {auth_token}' \
	-d '{
    "filename": "1.txt"
	}'
```


### Keyword Routes
#### Overview

| Method  | URL                                           | What to do                                     |
| ------  | ----------------------------------------------| ---------------------------------------------- |
| GET     | /api/v1/accounts/{uid}/{course_id}/{chapter_id}/makekeyword  |  Create keyword |
| GET     | /api/v1/accounts/{uid}/{course_id}/{chapter_id}/showkeyword  |  keyword of this chapter |


#### Example

**GET /api/v1/accounts/:uid/:course_id/:chapter_id/makekeyword**

```shell
curl http://localhost:9292/api/v1/accounts/1/1/1/makekeyword \
	-H 'content-type: application/json' \
	-H 'authorization: bearer {auth_token}'
```

```
{
  "data": "第 6 週: 進階持續威脅 (APT) 與入侵偵測防禦系統",
  "content": [
    {
      "type": "keyword",
      "id": 1,
      "attributes": {
        "course_id": 1,
        "folder_id": 7,
        "priority": 2,
        "folder_type": "slides",
        "chapter_id": 1,
        "chapter_name": "第 6 週: 進階持續威脅 (APT) 與入侵偵測防禦系統",
        "keyword": "{'比對': 19.0, 'IPS': 24.0, 'IDS': 31.0, 'intrusion detection system': 18.0, '特徵碼': 15.0, '電腦': 4.0, '晶片 ASIC': 4.5, 'APT': 45.0, '威脅': 22.0, '字串': 20.0, '封包': 15.0, '組織': 4.0, '警報': 5.0, '攻擊': 21.0, 'string': 13.0, '偵測': 14.0, '情報收集技術': 6.0, 'content 屬於第七層設備 layer': 6.0, '程式': 8.0, '需要': 7.0}\n"
      }
    }
  ]
}
```

**GET /api/v1/accounts/:uid/:course_id/:chapter_id/showkeyword**

```shell
curl http://localhost:9292/api/v1/accounts/1/1/1/showkeyword \
	-H 'content-type: application/json' \
	-H 'authorization: bearer {auth_token}'
```

```
{
  "data": "2016 網軍大進擊 ",
  "content": {
    "type": "keyword",
    "id": 1,
    "attributes": {
      "course_id": 1,
      "folder_id": 7,
      "priority": 2,
      "folder_type": "slides",
      "chapter_id": 1,
      "chapter_name": "第 6 週: 進階持續威脅 (APT) 與入侵偵測防禦系統",
      "keyword": "{'比對': 19.0, 'IPS': 24.0, 'IDS': 31.0, 'intrusion detection system': 18.0, '特徵碼': 15.0, '電腦': 4.0, '晶片 ASIC': 4.5, 'APT': 45.0, '威脅': 22.0, '字串': 20.0, '封包': 15.0, '組織': 4.0, '警報': 5.0, '攻擊': 21.0, 'string': 13.0, '偵測': 14.0, '情報收集技術': 6.0, 'content 屬於第七層設備 layer': 6.0, '程式': 8.0, '需要': 7.0}\n"
    }
  }
}
```

## Install

Install this API by cloning the *relevant branch* and installing required gems:
```
$ bundle install
```

## Execute

Run this API by using:

```
$ rackup
```
