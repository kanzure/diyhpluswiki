Name: c-lightning developer call

Topic: Various topics

Location: Jitsi online

Date: November 15th 2021

Video: No video posted online

The conversation has been anonymized by default to protect the identities of the participants. Those who have expressed a preference for their comments to be attributed are attributed. If you were a participant and would like your comments to be attributed please get in touch.


# Upgrading c-lightning for Taproot

So, Taproot. The one place in the spec where Taproot matters if you are using it as an individual, generally it doesn’t matter where you keep your funds when it is not in a channel, doesn’t affect the spec, except the shutdown case. We have a whitelisted group of things that you can send a shutdown to because you don’t want to be stuck with a non-standard shutdown. If the other side says “I want to send to this non-standard script” then your shutdown won’t propagate and this can lead to problems. We did add a feature that says “You will allow modern SegWit” and it went in a while ago. I think all things support it. You can do future SegWit versions including Taproot. If the other side supports that you can do a shutdown to Taproot. The rest of the time where you keep your funds is entirely a wallet decision. It should be very easy for implementations to flip the switch but it requires infrastructure. In particular I got everything done in c-lightning except for the part where we can actually spend the Taproot funds that we’ve received. That requires [libwally](https://github.com/ElementsProject/libwally-core) support and I’m waiting on that. I can’t guarantee that will be in the next release but it would be nice. At some point we have to question when do we start deprecating the wrapped addresses, if you want to do an old style pay-to-script-hash address. It is not a big deal to maintain that. We’ll either have to sweep them or keep handling them forever. It is already in the codebase, it is already tested and everything else but it might be time to start refusing to hand out new ones.

One interesting thing about moving everything to Taproot, I was reading a [tweet](https://twitter.com/n1ckler/status/1334240709814136833?s=20) from Jonas Nick that you can do ring signatures to prove reserves of Taproot outputs at a given height. One reason you’d want to upgrade to them is you can prove you have a given output amount. That’s important for liquidity ad stuff, if you want to ask someone how much available balance they have, they could give you a balance? I think you can verify that someone had that balance at a height? Maybe it is just output ownership in a set.

I don’t know about balance but he did ownership within a set which is kind of similar. Obviously for a while we won’t have enough Taproot outputs to make that very anonymizing. There has been speculation we could use a similar ring signature for gossip, you prove a channel. That is more interesting. It is doesn’t really work the way we do channel announcements today because we link them to a specific UTXO and you can tell when it is closed. If we switched to using some proof of UTXO for node announcements, as we’ve discussed inverting our gossip, that starts to be really attractive potentially. Except for the size issue and the fact that to validate it you would have to keep a snapshot of the eligible UTXOs at particular heights. They say “I have a UTXO, here’s the proof”. You need to somewhere have a set of UTXOs at the height that they are trying to do the proof at. You can batch it and say “You can only prove these once a day or every how many blocks” but that is still things you need to keep and infrastructure that doesn’t exist. It is still sci-fi at this point but it is interesting sci-fi. 

I guess you have to be clear on what part of the Taproot upgrade we are talking about. I think what you were talking about is paying out to pay-to-taproot (P2TR) addresses from your channel. I understand when you say that doesn’t need to be subject to the “two implementation” rule. But something where the 2-of-2 is a P2TR, then we are in the world where we definitely need two implementations and perhaps you want even more than that because it is really a network thing…

It doesn’t affect the rest of the network. If you and I agree on some weird protocol and it falls over our channel is screwed, it is between us. That is the good news. It doesn’t completely affect everyone if we mess it up. But yeah that is something we would want a lot of eyeballs on. That was way beyond the weekend project I was planning. That is a big deal. There is a lot of enthusiasm to do it and it is definitely the road. You start doing the MuSig thing, you start going “Now we’re going to do eltoo” and all the goodies. It is definitely going to happen but not on a weekend I don’t think.

# Individual updates

I opened the ports [PR](https://github.com/ElementsProject/lightning/pull/4900) but I have not done much since then. I would like everyone to have a look and comment, give me some feedback if you think anymore documentation needs to be changed or something. If you have patches that is ok of course, I’ll be happy to do my homework, just point me to something which I did not notice myself.

Which PR?

PR 4900. I have tested it and it works for me. 

It is mostly just documentation and changing the port number. There is a change in the tests, what is happening in the tests? Why is there something that is looking like a hash changing?

Did you touch the DB file?

A small change in the tests because there was the port and the port is encoded in hex. I needed to change the default port encoded in hex. I needed to change that default 9735 into regtest default port. 

That’s testing the gossip message coming through the wire in that test that we get bitwise exact. That’s why it has to change. It is not a hash, we are doing a hex dump of the message going across the wire. And of course the gossip message has now changed because it is a different port number. That one is pretty explanatory. We have had a lot of CI flakes recently. I’ve been trying to whack them. I suspect that they have lowered the ceiling on the GitHub runners and we are getting out of memory (OOM) and I am not quite sure how to deal with that. I have been tempted to add a demessage at the end of our runs to see if I’m getting OOM killed. We are getting exit with code -9 which normally means SIGKILL. This almost always means you’ve been OOM killed.

What is really annoying about this CI runner is that you can’t restart a single job. I think there is no option to do it, it is very bad.

Yeah absolutely. You have to whack the whole lot to rerun it. It seems transient. I have tried to do some things to reduce memory. The main use of memory is of course we run the whole test suite under Valgrind. That has proven useful in the past, I am reluctant to give it up.

It wasn’t the checksum of the plugin was it?

You changed something about the checksum calculation in the plugin to see if it allocated additional memory?

Yes, I ran the whole thing under [Massif](https://valgrind.org/docs/manual/ms-manual.html), the heap profiler. The big spike in startup was basically pulling in all the plugins to do the checksums. We can get rid of that. 20 MB, we have got a fair number of plugins now and they have got all the debug information and everything else. We literally pull in the whole files to checksum them. Under Valgrind it uses a multiple of memory. If we are firing up a lot of nodes at once perhaps it is doing something. 

It wasn’t a memory leak or something?

No as far as I can tell it is not a memory leak. We are not seeing massive increases in memory. We’ve got enough options on Valgrind to try to cut the memory usage down but we have perhaps hit some ceiling. I think you can run external runners with GitHub. If all else fails we have to outsource it to Google Cloud or something to get some more beef behind our CI but it is painful. Mundane things, not exciting things but sometimes software engineering is a lot of mundane things. 

Congratulations for the release in case it wasn’t already mentioned before. I was waiting for the cleanup PR which is now on master, I rebased my stuff. There is one thing still missing, it is about the [DNS PR](https://github.com/ElementsProject/lightning/pull/4829), I think you left a [comment](https://github.com/ElementsProject/lightning/pull/4829#discussion_r746146256) that I didn’t fully understand about the Valgrind issue. You were mentioning something, I should add the port number as a local variable but there is no port number in this specific snippet so I was confused. Maybe I take the time to go through it myself. All the other remarks I already finished them up, it is just that one point. 

You initialized a variable and you said that Valgrind complains for the next iteration. Yes, Valgrind complains, the problem is not that Valgrind complains, the problem is that there is a real bug here. That is because you resized the array and when you resize an array it can get reallocated and moved. The old pointer was pointing at the end of the old array. When you try to update it…. That’s why Valgrind complained. Your comment says it fixes Valgrind complaints for the next iteration. Well, yeah.

I am resetting the old pointer. No?

That is what it does. But the comment says you are doing it to keep Valgrind happy. No, you are doing it because it is a bug. You are doing it because it needs to be updated.

Do I need to free the old array then?

No. We’ve got an array and we’ve got a convenience variable that points into it. The array moves, we need to update. There is nothing wrong with the code, it was your comment saying that it is because Valgrind is complaining that made me twitch. Valgrind is complaining because you’ve got a bug. Valgrind does sometimes give spurious things but they are quite unusual. In this case it was really catching something that I wouldn’t have seen. This is why sometimes I really dislike convenience variables. They can get out of sync. In this case Valgrind saved you, it was right.

I guess the fix is to remove the comment?

A comment is useful. “This may have moved” is useful.

But not to blame Valgrind.

I don’t have a bug but the comment is wrong. Now I’ve got it.

You were mentioning something about portnum, or ZmnSCPxj did. This is not part of this code so I was confused.

ZmnSCPxj said that you should be saving portnum in a new var. 

The reason we have the addr variable is simply to access the port number. Rather than have that temporary variable that has this problem where you have to keep it updated you can just save the port number. If you zoom out on the code you’ll see what he is talking about. The only reason we keep that around the loop is so that we can access the port number. But just save the port number and then this whole problem goes away.

Portnum is not part of my code but I will have a look.

When the code gets subtle you start thinking about how I can sidestep this whole problem. This is nicer.

Once I get CI beaten into shape then I am hoping to squeeze all these PRs in. I am release captain for this release which at this point is looking like mid January. I think we are going to go longer for this one. There is some stuff I really want to get in. 

# Accounting plugin update

I am working on redoing the way that we do accounting in onchaind. The long term goal is to produce this much promised accounting plugin that can give you a statement of accounts etc. On the way to there part of what I am doing is redoing when we emit events. Previously I was trying to do a rollup in c-lightning where we would try to figure out how much you were paying for chain fees and log them as chain fees from c-lightning. Create an event, I’m going to call it a synthetic event, the chain fees. That becomes a lot more complicated with things like a multi funded channel or if we move to closing a channel with multiple closes etc. This is very difficult. I am moving from reporting chain fees to a model where the plugin will be able to figure out what the chain fees are based on the inputs and outputs. The only events that c-lightning is going to log is UTXO movements for onchain stuff. I am almost done with the onchaind cleanup. I just need to make sure all the tests still pass, rewriting some output stuff. I think it is going to be a lot better in terms of quality of data we are producing. Really the accounting project is a data project, logging project. I am hoping I will be able to wrap up the logging part today or tomorrow, the rewrite of the logs, and then get started on the plugin which is the exciting fun part. There was a problem when you start, what’s your starting balance? I still need to figure that out.

Accounting is vital and yet it is on the back burner continuously. It is never on fire. It would be good to have this in the new release.

One exciting thing about it is I think it is going to start exposing our onchaind. It will be easy to track improvements when we make them to how we handle funds onchain which I think is very exciting. 

I see a lot of people saying “Look I made all this money forwarding” but without a full accounting of how much they submit on fees and rebalancing and everything else. I think it is a bit of a mirage to some extent. Having a sat by sat view of what happens with your funds is actually important, just for the metrics not to mention tax time. It is very, very cool. I am looking forward to it.

# Individual updates (cont.)

I have been balancing my time between [Greenlight](https://blog.blockstream.com/en-greenlight-by-blockstream-lightning-made-easy/) and c-lightning. The big thing that I’m planning to do for the next release is to overhaul the way that we track information that we gather while making a payment in the network. That includes failed payment attempts, updates that we collect while doing payments, adjusting fees, adjusting capacities and these lifetimes. Coming up with the model that allows us to time these metrics out. If we’ve seen that at 8am we had 25 percent of the capacity on one side then we will slowly increase that over time until let’s say 4 hours later we assume that the upper limit is 100 percent again. That should allow us to have more information across individual payments and speedup follow up payments once we have learned some parts of the current situation in the network. That is not a hugely necessary change at the moment because there are very few people that make multiple successive payments but what it does help us is to reduce the complexity of the way that we handle this kind of data at the moment. We currently have three different systems to do so. We have the gossip that we get from our peers, we have a local mods overlay that Rusty built that was supposed to unify everything but I haven’t taken advantage of it yet. And we have the old classical exclude base system where we go through a list of known channels and check whether we would be suitable for this channel or not. If not then we just exclude it for our next pathfinding operation. Molding that all into one single model will eventually allow us to not only reuse some of the information we have on the network but also come up with some more interesting models to compute our routes. One particular one of course being Rene’s min cost flow. Having this information about the capacity on an edge is important and not just yes/no for a given value which is what we currently have. It should become a nice cleanup in the end. I am really looking forward to that. Other than that I have been spending my time in Docker and PPA land. I am really starting to hate the Launchpad PPA because it does not allow us to actually talk to the internet while compiling stuff. We now have to re-add all the derived files because we cannot download Mako and MKRD on the Launchpad. I am now in a situation where I’ve changed up the build release script that we use for the zip files and for the Fedora builds. That now has two new targets. It has a Deb target that builds the Debian package on the current machine. And the tarball is basically just a zip file in a format that Deb build will understand. The `xz` format is not known by Debian tooling. And it also materializes all the derived files again. It clones, it derives all the files, it exports everything from Git and then smashes it into a tar.bz file. That works. However Launchpad PPA does not allow me to upload tarballs or pre-build Debian files. I’m really looking forward to the day that GitHub will allow us to host all of our packages on GitHub proper and we can integrate all of this into the GitHub Actions workflow which Lisa pointed out, we can actually do at the moment for Docker. I’ve been looking into how we can automate the Docker deployment using GitHub Actions and not have these sudden rushes at the end when we are about to press release but have nightly builds on one repository and the second repository just having the releases being built. That is what we already do for PyPy. Going forward I want to automate as much as possible ahead of the releases so that all of this knowledge that we have for a couple of people that know how to package stuff doesn’t have a bus factor of 1. Reading all of this cruft about building Debian packages is really, really painful and I don’t want anyone else to have to do it. That’s my little rant.

# GraphQL in c-lightning

I have also got the task from Robert (Dickinson) to mention a couple of points on his side. He has written a really good summary which I would probably share directly in the channel. I will quickly summarize it and he can share it later.

“My status for open developer meeting... (mainly GraphQL PR.)

Main points:
Most review comments have been addressed from my side. There are one or two non-impacting changes that I plan to do as time allows.

The biggest change since it was reviewed was to refactor the first pass of the GraphQL command processing to use tables instead of giant if-else-if switches. This change resulted in the code being more organized, in pushing more of the redundant logic into common functions, and making the implementation more copy-pasteable to other areas of the codebase. A great improvement, IMO.

I added "from" and "to" arguments to demonstrate querying a subset of a long list—a need that was mentioned recently in Telegram. There is a screenshot in my latest PR comment to show how that looks to the user.

There was one review comment I would like to have reconsidered. It was a great suggestion to introduce a middle layer (a tree structure) between GraphQL and JSON output, but at this point (with various code improvements having since been made) I am of the opinion that it will only add unnecessary complexity with little benefit. In essence, such a layer is what we already have by piggy-backing the parameters and other relevant data onto the abstract syntax tree in preparation for generating the JSON output, and now it is even a lot more unform and standardized as a result of the new table-driven approach. Furthermore, the functions that generate the JSON output are unaware of anything to do with GraphQL and could be used anywhere (e.g. consolidated into existing JSON output functions). This is already a clean isolation line between GraphQL and JSON output, which can be exploited as needed. So, my opinion at this point is to NOT add another layer.

Overall, going forward:

I am eager to start expanding this capability to other RPC methods as soon as the code/approach is approved.

It was noted in Telegram that GraphQL will increase the learning curve for CLI users. I think some good user-oriented material can bridge that gap.

General question from my side: Now that Taproot is active, I'm curious how c-lightning relates to it, and what opinions the team has on the topic.”

He has been busy working on the [GraphQL interface](https://github.com/ElementsProject/lightning/pull/4862). He has addressed most of the feedback that he got on the PR and I will definitely take a look at it as well. There are a couple of things that I’d like to make sure when we add a new interface that we respect. One thing that intrigues me personally is that he moved away from having the if, else structure for each individual field that might or might not be in the request. He went more towards a map based system where you can enable and disable individual fields. That is definitely interesting. I definitely want to look into that. This if, else thing was getting really noisy. I was wondering if we could move it into the JSON star family of functions because that sounded like the right place to do it. I am curious about what he did. He also has a couple of feedback requests. One is that the GraphQL interface will increase the learning curve for new CLI users. First of all is that something we should care about? Can we make sure that it doesn’t get too complicated? I was always under the impression that a GraphQL query is just a RPC endpoint plus a list of fields or a structure of fields that describes what the reply is that we’re expecting. Hopefully we can come up with a default structure that we can provide new users with so they don’t have to learn about the GraphQL query structure but still get the current system where you issue a command and you get the result. He has also looking at extending his coverage from the RPC methods that he currently has into other RPC methods and I am thinking he current does `listpeers` which is probably the place where this is most strongly needed. But if there are other RPC methods that are starting to get unwieldy it might be a good time to tell him and maybe give some proposals about how they could be improved. And he was asking about Taproot. We had a couple of things at the beginning about Taproot and so I will refer him to Michael’s awesome write ups.

The GraphQL is really interesting. There was a lot of back and forth on the PR. I really like it… GraphQL is like REST 2.0. It lets you say “Here’s the responses that I want” so you can select which bits you want back. Ideally a good implementation will do a lot less work. “I’m only after this bit of each query”. The way it was structured internally was this huge if, else thing. Do they want this? Do they want this? Do they want this? I said that is unacceptable, what we really want is you by default produce all of it and it just throws away the bits that it knows the user doesn’t want. We can optimize that more later. By having it return bool, you can do filtering inline if you want. “They are not interested in this whole object, I don’t need to generate it” or “I don’t need to calculate this because they’re not interested in”. But naively you can just keep the same code that we’ve got now which is generate all the fields. There is a problem there in that the GraphQL spec requires that you answer them in the order they ask them for. So you can’t just whack them out into JSON, you do need an intermediary representation. That’s a problem because it breaks streaming but it is not a problem in that all of the things that we stream at the moment are actually from plugins, all the things we really care about. It was `listnodes` and `listchannels`, the ones we really needed JSON command streaming for. They are now all in plugins anyway. We care a lot less than we used to so I said “No go for an intermediary representation, that’s fine, but just hide all the complexity from the person who is trying to write the JSON output”. I’ve been hitting refresh every few days on that PR so I’m glad that he has made progress. Having GraphQL will be nice.

The streaming support is only needed when we are streaming a list? Channels and nodes, those are the ones that are really huge. Everything else is derived from an in memory representation anyway. I guess streaming only makes sense if you have these huge lists of things right?

Yes, exactly. Since the topology plugin they are all in plugins. I don’t care, we can just do it that way. And remove the streaming ability, nobody will mind. It will still be streamed because we stream through lightningd but you’ll assemble it all and send it off. GraphQL will not obsolete the current JSON interface, it will complement it. It is not like everyone is going to have to learn GraphQL, it is cool for people who want it. The other point to make when you are going back to the pay plugin is of course we had a significant improvement with a simple tweak to our pay plugin but it still doesn’t keep state between payments. You tell it to pay something, it tries these things, learns all of this stuff about the network and then throws it away. Obviously with Greenlight, we are hosting nodes, potentially they are making more payments, more vendors doing stuff like that and more general usage where people are seeing higher rates of payment. It is nice to keep that information around if you’ve got it. You might learn some interesting things about the network that would be good. Although our success rate is now pretty high obviously we could do better. I am looking forward to that as well. My node, unless I do another payment test, is unlikely to ever really use that code. I’ve got to make more payments.

The GraphQL thing seems like a good opportunity to introduce a HTTP proxy for that particular endpoint because doesn’t the GraphQL let people decide what they want to ask? In terms of supporting a HTTP thing, it is very low maintenance on our end? I have been fielding requests from Voltage, “We want to support c-lightning but we need a HTTP thing”. If we get GraphQL it seems like there is a pretty straightforward path to exposing that as the endpoint?

Yes. That is the way most people would expect to use GraphQL, over HTTP. But I think probably a plugin that does it is the right way to go. Your HTTPS, SSL stuff, we don’t want that in the core. It would make sense to make that a plugin. Absolutely, that would be great. Are you volunteering to do that?

Can it be a Rust plugin?

It could be a Rust plugin.

Ideally we would ship it with the binary.

That is coming soon. We are going to have to start shipping Rust. 

We can make it dependent on whether you have Rust or not. If you compile it the releases will definitely have Rust and we can ship binary Rust. The one thing that I’m not sure about is whether Rust is reproducible as of now. It might end up breaking our repro build at the moment. I will look into that though.

<https://users.rust-lang.org/t/testing-out-reproducible-builds/9758>

<https://github.com/rust-lang/rust/issues/34902>

It has to be.

It is a new language so hopefully they would have taken care about that. But not 100 percent. The reason why I’m asking for Rust is because I looked into HTTP libraries in the past, in particular curl, and that really doesn’t mesh at all with the I/O loop stuff. We either have to swap out the I/O loop anyway but at that point we can do something completely different as well.

I like it as an excuse to put our first Rust plugin in, that is all good.

You are volunteering to do a HTTP endpoint plugin, thank you.

Sure, need to come up with authentication, encryption…

Those are solved problems right? (Joke)

We can do macaroons now,

Runes, Rusty’s runes. 

# Individual updates (cont.)

vincenzopalazzo: I have a plugin that makes a REST API but it is in Java and it is not very good at all. The JVM consumes more RAM than lightningd. It is enough to run my server. I can implement something with Rust because I have a library that I extended from a maintainer of Bitcoin and I need to implement the plugin API. Maybe I can implement something, make my Java plugin in Rust basically. I need that, it is very expensive for running a small server with Java, it is very bad. About my work on c-lightning, I opened a [pull request](https://github.com/ElementsProject/lightning/pull/4908) in draft addressing the error that openoms told us last time, the error handling when we have the HTLC encrypted. Basically when c-lightning checks whether the HTLC is encrypted or not it requires the password. Openoms had a problem in Raspiblitz, it is not able to catch if the HTLC is encrypted before running c-lightning. One possibility is to check the error that c-lightning gives but from my understanding this is difficult, I don’t know if there is a possibility to change the error… It is statically `1` inside the code. Before changing a lot of stuff I wanted to ask. I am doing some Matrix stuff to build a GraphQL server and a plugin that does the right job and doesn’t crash.

I am looking at your PR now, yes you should move those to somewhere else. You should expose the definitions somewhere and make sure they are documented in the man page. I guess the question is which error?

vincenzopalazzo: The question is what is the value of the error that lightningd… 

You start from `1` and start increasing and don’t go above `127`. That’s fine. HSM errors being `20`, they are arbitrary numbers, it doesn’t matter. 

vincenzopalazzo: The second question, we check if the HTLC is encrypted only when we run the command line? The command line, the static error code is `1`. I don’t know if this is customizable in some way?

It is all code, we can fix everything. It depends where it is exiting with the error. There is a general thing you call by default and we can change the default, we can change the way we handle errors to our manual error handler rather than using the CCAN default one. I think that will fix it. There is an error in exit, handling it by default inside the option parsing. That, we can not use the default one, we can have our own. It is possible for us to write our own and not use the default one that exits `1`. It is fixable. 

vincenzopalazzo: It makes sense there is only one error for the command line. Maybe there is some different way to check that. My idea is only to change the default error by command line.

You want all command line errors to have a specific unique error number if it is a command line parsing error? It will be `19` or something for “I couldn’t understand the command line”? Is that your thinking?

vincenzopalazzo: Or we leave `-1` and a generic error by command line or all the command line has some error code. “That command doesn’t exist” error or something. This is my idea but I don’t know if this is too difficult to implement. This from Raspiblitz is very easy because bash can check very easily the error code.

Differentiating between “This option doesn’t exist” and “You spelt this option wrong” is a little bit more difficult but I can look at how we would do that. If you go “Option foo equals 1 to a” and expecting a number, that is a different error from “Foo does not exist as an option”. If we want to differentiate those that is a little bit more difficult. But all things are possible if we really want to. It may be overkill, I think the HSM error is a good start. That is what he really needs to know if it is a bad passphrase and that is useful.

vincenzopalazzo: I will work on this this week.

Other than trying to shepherd things through various CI issues there are some minor cleanups but the really significant thing that I am working on is trying to get [multiple channel support per peer](https://bitcoin.stackexchange.com/questions/110497/why-doesnt-c-lightning-allow-you-to-open-multiple-channels-with-the-same-peer) for the next release. This has been a big thing that people have asked for for a long time. There were reasons to push back on it, there are still are to some extent. One is that we are supposed to do splicing. But that has been delayed. Even when we do get splicing in draft it will only be between c-lightning nodes so it won’t be a solution for other nodes. The second argument, which is quite convincing, you increase fragility if you are relying on a single node. You should ideally be connecting to multiple separate nodes if you want to increase your capacity. But sometimes that isn’t possible and you really do want to connect to a single node. Of course closing a channel an reopening has downtime. For this reason I am looking at rearchitecting things so that we can do multiple active channels to the same node. This is a significant change but I think one that we are going to aim for the next release. It is one reason to defer the release, not commit to a release in 25 days. We will be doing that, as much as I can commit to something I haven’t actually coded up yet. That is my plan. Other than that, removed a whole heap of deprecated stuff, removed Tor v2 support. The Tor v2 network is officially dead. The current release of Tor doesn’t support Tor v2 anymore. I expect the network to fall apart fairly quickly and definitely by the next release. It did not get the full deprecation cycle, we normally go for at least 6 months. I would normally have waited another release before removing a feature that we deprecated.

It will be staying part of the spec for infinity though?

Someone will put a PR to remove the number from the spec and that will happen. It will just become an ignore though. We will still display it forever.

# Q&A

In the Telegram chat I have four channels that have `CHANNELD_AWAITING_LOCKIN`, even though the transaction has been mined for 1000 blocks. What can the cause be of that?

Your peer might not be exchanging the lockin message.

But what might be the cause of that? I have 5 peers doing that.

They have sent it once, they might not resend it?

Do we always resend funding lockin even after it being buried deeply?

Yes. You are supposed resend `funding_locked` unless you’ve got an existing transaction. If you reconnect and your commitment count is `1`, meaning that you haven’t actually done any initial commitments you always retransmit `funding_locked` so that this doesn’t happen. Once you’ve had commitments that implies the other end has received, you have both exchanged `funding_locked` and you are happy to forward. If you reconnect to them they should retransmit `funding_locked`.

I need to reconnect? I currently can’t tell my lightningd to disconnect because I have an open channel with them.

You can force disconnect.

That is safe to do?

Yes. It will immediately reconnect.

Could these have been really slowly confirming channels? Like 2 weeks?

No, absolutely not.

That’s a bit of a corner case, if they don’t confirm for 2 weeks then they confirm. Then your peer who is the fundee will forget about them and you will wait indefinitely. 

Force disconnect and reconnect. I don’t know why this happened to me. It is locking up a significant amount of funds. Is there a way to detect this and do this internally after a while?

It is not us, they haven’t sent something we expect. We are waiting. 

I know that it is not us but we could try to fix that on our end if we see that.

If you force a disconnect it will automatically reconnect. We don’t actually need to reconnect, it will start the reconnect loop because it has a channel with it, it needs to talk to them. See if that fixes it, if it does potentially we could put in a timer to say “That’s funny, you haven’t sent it and I really expect you not to be that far behind”. You could cut them slack in case they are lagging.

I forced the disconnect, it is again connected, now it is normal. Good.

Is this LND on the other end?

I don’t know. I just used some plugin to open new channels. Half of them stopped responding. 

That’s weird. Debug logs will tell you all the messages you received.

I am quite sure I’m not the only one having this issue. It raises some questions. I wasn’t very concerned about it because normally when funds appear to be missing they are not really missing, they are just not accessible for some reason.

It either didn’t send it or it sent it too early and we ignored it which is possible. Was your bitcoind lagging for some reason?

No. I was running not the current release, the one before. It is interesting that happened all at once. My guess is that they sent it and for some reason we weren’t ready for it and they did not resend it which they would not. We should have acknowledged they’ve sent it once we’ve sent it. The other possibility is that we didn’t send it, it is actually our fault if we are looking at bugs. What level logging do you use? Do you have giant logs?

I prefer giant logs. Debug level logging.

If you look for `funding_locked` it will be interesting to see if we thought we sent it, if we thought they sent it, what status we are in at this point.

What part of the code is sending and receiving this message? It is openingd?

Yes.

So I need to check the logs to see if openingd crashed and was reconnected?

I don’t think it is a crash and reconnect because we’ll get that case right.

Assuming it is not a bug on our side and the remote is doing something wrong or not resending it for whatever reason then we should maybe have a failsafe to say “The funding transaction has been mined for that many blocks, let’s try to reconnect”?

There is a general issue of if a peer is going wonky for whatever reason we should just try reconnecting as a first step. For example we haven’t heard from the peer in a while or other things. We now have pings inside channeld where we will do live probes just to check they are still alive. We hangup and we try again if those fail. But at a higher level there is perhaps some kind of progress. If they haven’t locked in and we expected them to we would do a similar thing.

What would be the criteria upon which we would decide to try to reconnect?

Six blocks, six is the magic number in Bitcoin.

If our funding transaction has been mined for 7 blocks and we didn’t get the `funding_locked` then we just reconnect.

Yes, greater than 7 blocks. Every time we get a block in if they still haven’t reconnected just try reconnecting. At this point the channel is kind of useless anyway. Dropping the connection and trying again doesn’t really hurt us. That code is pretty simple. There is somewhere we monitor the depth and we can look at it and go “The channel is not in the right state. That’s weird, let’s kick it”. If it is connected just kill openingd and all the magic will work. Log a message so they know why.

Now my funds are back, great.

Your node is too reliable. If you’ve got 1000 blocks that means you have been up for a week. You are not upgrading fast enough. If you upgraded your node you would restart everything.

I didn’t want to restart it because I was not sure… Sometimes doing something without knowing causes more pain.

Plus it is harder to diagnose afterwards if you’ve done 28 different things.

Speaking of recovering funds, we finally managed to recover the last couple of funds by that one user who almost lost 2 Bitcoin. It turns out that PhotoRec is really useful to recover database backups as well. We just needed to write a description file that tells PhotoRec that the header of our backup files is a photo. Now we can actually look through broken disks and look for backups that were on it once in a lifetime.

That’s kind of cool. I thought his SD card blew up?

His USB stick, that had I/O errors, that’s true. So what we did was take an image using Didi and then on the image you can actually start carving out the files by looking for file headers on the raw blocks. By doing that we recovered not one database backup but 11. Then it was just a matter of taking all of these backups, replaying them into a SQLite database and then looking at which one had the highest data version. We took that one, started the node again with it and voila all the channels, the ones that weren’t unilaterally closed by the peers, he was able to recover those. He did an unilateral close on a tiny channel and lost those funds because he couldn’t connect to the peer to trigger them to close. But it is only like 15 Swiss Francs so that is like one coffee. It is way less than 2 Bitcoin.

SD cards tend to die, they die big. I’m impressed that this died small. Usually it is all gone. You lose big chunks and the whole thing becomes unresponsive in my experience. It is very lucky that he only got I/O errors and he had something left to salvage. We need a better backup solution, I think that’s the story to take away here. I would have thought everyone knew not to run off a USB stick without backups but ok, here we are. Well done, I’m impressed you got that back.

He was having a SD card for the backup?

A USB stick.

I also have a USB stick for the backup. He lost both of them at once? What was the problem?

Yes, more or less. He was in the process of compacting his backup and was in the wrong directory and deleted the wrong file. He did not notice that and then compacted the real database which then caused the failure.

SD cards and USB sticks are not really made for large numbers of writes. Especially rewrites. The backup plugin does have the same exact number of disk accesses as the main database because we need to write out the changes in realtime as they come in. There is no way for us to save on the number of disk accesses directly. Definitely don’t run the main database on a SD card or a USB stick. If you do the backup pay attention to I/O errors. And when your USB sticks crashes replace it quickly, you don’t want to be in a situation where you think you have a backup and get careless about the actual live data. The backup has one advantage, it only does sequential writes. It doesn’t seek, it doesn’t rewrite, it should be ok for media that has very few read, write cycles in their life. The problem is that SD cards and USB sticks have a fixed size block that has to be written as a whole block every time when you want to append to it. These blocks are usually 4K. If you have many, many small changes inside of this 4K range then this block gets rewritten all the time counting down on your write cycles which is the lifeblood of your storage medium. Once that is exhausted you won’t get back your data from that medium.

It is ok as a backup but it is a backup so you can still fat finger both of them at once. It is not a bad solution but don’t run your main database off of a SD card or a USB stick. The idea of doing a pure backup here would have definitely helped. It is a much more user accessible solution than having these manual backup solutions. I’d really like having that because it would just work for people.

How much of that 2 Bitcoin did he give to you?

Zero.

Such a nice guy. 

It is much better to learn from other people’s disasters than your own. There is a certain amount of relief.

To be perfectly honest I am so happy that no funds were lost because I do feel a certain ownership on stuff that goes wrong with our software. I am really happy that we were able to help somebody out.

He did the mistake and not the software.

Yes.

I agree, I was very impressed you got that back. 

The good old days when we didn’t have a database and didn’t persist any data across restarts. 

That is very old. I think 0.5.2 was the first version that I helped build and that was with a database.

0.6 is considered modern era I think. 0.5.2 predates the spec.

My PR with the DNS, I fixed the comment. The CI seems to be running good, maybe re-review in a couple of days.

I will keep trying to push our CI and try to figure out what is going on there. I did some memory reductions and it still happened to me on one of my PRs. More radical surgery may be required in which case I will ping Christian and ask how we do that.

Openoms says hi from El Salvador in the chat.

If you were to use a SD card or a USB stick then perhaps static channel backups make more sense because then you are not writing to them as much?

As a matter of fact what we ended up using was pretty much static channel backups. If you look at it in a roundabout way. Static channel backups are just a small container that contains just enough information about the channel. You know who to contact. We had a subset of the information as part of the database backup. We just couldn’t reconnect and resume like normal because it wasn’t the latest state. Then we also used a couple of extra tools in the form of the guess to remote tool which does a bit of fixing and you can recover a sort of channel stub that you can then use to reconnect to your peer and grab your funds from them closing it. I don’t think there is too much left to do before we can get static channel backups but I’d need to look into their format and see what information they store. It should be doable.

I like the idea of putting that information into the peers. Any peer that manages to connect to you will give you that backup. At least you have something to start from. More ambitious is having the whole state but at least having that map of who your peers are would be pretty nice.

Then all you need is to look at the gossip to see who were your former peers and once you know that you can connect to them, retrieve your stored blob which then tells you all the information that you need to recover the funds for an eventual channel. It is sort of doubles down on the fact that you are relying on the peer to actually close. That’s what SCBs do, you are in a lame duck mode and you go “Hey I don’t know what to do. Can you close on my behalf?” That is pretty much “I’m helpless, please help me”. If the peer wanted to blackmail you that could definitely happen. You’ve just told him “I’m in a bad situation, please give me my funds, pretty please”. Now them also having to store the data is not such a big leap from me having my own file. Since it is encrypted you can have additional information cross-sharing between peers. I am giving Michael information about my connection with Rusty and with Vincenzo. I need to connect to Michael to know about all of my other channels basically.

That would be good but someone needs to look at the spec and make it work.

The SCB spec? Does it exist?

No the [pure backup spec](https://github.com/lightning/bolts/pull/881) that t-bast did.

