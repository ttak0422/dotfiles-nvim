.PHONY: update-track

update-track:
	nix flake lock --update-input v3-track
	git diff --quiet -- flake.lock || (git add flake.lock && git commit -m "chore(track): update input" && git push)
