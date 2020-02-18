
root_url = "https://diyhpl.us/wiki/transcripts/coordination-of-decentralized-finance-workshop/2020-stanford/"

file_data = [
    {
        "author": "Shin'ichiro Matsuo",
        "filename_stub": "opening-remarks",
        "title": "Opening remarks",
        "twitter": "@BSafe_network @ShaneMatsuo @byrongibson @CBRStanford #SBC20",
    },
    {
        "author": "Byron Gibson",
        "filename_stub": "catastrophic-instability-source-mapping",
        "title": "Mapping sources of catastrophic instability in dFMI",
        "twitter": "@byrongibson @CBRStanford #SBC20",
    },
    {
        "author": "Tarun Chitra",
        "filename_stub": "stress-testing-decentralized-finance",
        "title": "Stress testing decentralized finance",
        "twitter": "@tarunchitra @CBRStanford #SBC20",
    },
    {
        "author": "Mark Miller",
        "filename_stub": "constraining-compositional-risk",
        "title": "Constraining compositional risk in interconnected smart contracts",
        "twitter": "@agoric Chief Scientist Mark Mller, @CBRStanford #SBC20"
    },
    {
        "author": "Bram Cohen",
        "filename_stub": "consensus-protocol-risks-and-vulnerabilities",
        "title": "Consensus protocol risks and vulnerabilities",
        "twitter": "@bramcohen @CBRStanford #SBC20",
    },
]

for data in file_data:
    filename = data["filename_stub"] + ".mdwn"
    url = root_url + data["filename_stub"] + "/"
    title = data["title"]
    twitter = data["twitter"]
    author = data["author"]

    sponsorship = "----\n\nThese transcripts are <a href=\"https://twitter.com/ChristopherA/status/1228763593782394880\">sponsored</a> by <a href=\"https://blockchaincommons.com/\">Blockchain Commons</a>."

    tweet = f"Transcript: \"{title}\" {url} {twitter}"
    transcript = f"{title}\n\n{author}\n\n\n{sponsorship}\n\n\nTweet: {tweet}\n"

    fd = open(filename, "w")
    fd.write(transcript)
    fd.close()

