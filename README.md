# quantaxion-site

The public landing page for [QuantAxion](https://github.com/ncanerozturk-cloud/QuantAxion),
deployed separately so the marketing page can be live while the application is not.

Two static files and no build step. That is the entire point: the research
application is thirteen services, a TimescaleDB instance and nine Celery
workers, none of which fits a serverless host — but the page describing it is
plain HTML and belongs somewhere free and instant.

| | |
|---|---|
| `index.html` | the landing page, including the worked CRDO example |
| `login.html` | access notice — the application is not reachable from here |
| `vercel.json` | clean URLs and security headers |

## Deploying

Connect this repository to Vercel and accept the defaults. There is no
framework, no build command and no output directory to set; Vercel serves the
files as they are. Custom domains are added under **Project → Settings →
Domains**, which prints the DNS records to create at the registrar.

## Keeping it in step with the app

`index.html` is a copy of `src/api/static/landing.html` from the main
repository, with the `/login` links repointed at the static access page. When
that file changes, re-copy it:

```bash
./sync.sh ../QuantAxion
```

The script does the repointing, so the two copies cannot drift in the one way
that would matter — a live button going somewhere that does not exist here.

## What this is not

This is not the product. Nothing on this site reads market data, calls a model
or reaches a database; the demo is a transcript of one real saved report, which
the page says plainly. The application is deployed separately — see
`docs/DEPLOY.md` in the main repository.
