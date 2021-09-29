Name: c-lightning developer call

Topic: Various topics

Location: Jitsi online

Date: September 20th 2021

Video: No video posted online

Agenda: https://hackmd.io/@cdecker/Sy-9vZIQt

The conversation has been anonymized by default to protect the identities of the participants. Those who have expressed a preference for their comments to be attributed are attributed. If you were a participant and would like your comments to be attributed please get in touch.

# Individual updates

Let’s start with a quick round of updates from the team. Then I’ll give a brief overview of where we stand with the release. Then we can get into some deeper topics. I picked up one of my pet peeves which is removing derived files. I think it is time to evaluate whether we should continue doing that or not.

I have been mostly helping the continuous integration system to run through. We have merged quite a few of the pending PRs. It is just a matter of rebasing and getting them to run correctly. I have been working on getting the PyPy packages to automatically be deployed from continuous integration. That is working currently against the test instance of PyPy. Every time we land something on master it gets built and pushed to PyPy. I am planning on hooking into the version being tagged and to have that deployed to the actual production version of PyPy so I can no longer forget to publish those as I’ve done so often in the past. Besides that I am on working on getting BSD and MacOS to work on continuous integration. We had a couple of issues with the recent cleanup of include files that were correct on Linux based systems but BSD seems to have some missing links between the various header files. We have slowly been re-adding the inclusions that we cleaned up before. But way fewer so that is good. The BSD version seems to be working ok and the MacOS version seems to be hanging on the tests. I am intending to only run them without Valgrind, have a quite iteration run not checking for memory issues on MacOS. But it should at least give us the confidence of maintaining compilability on those systems. Just like we do on the ARM 64 and ARM 32 versions. I have also heard about an issue with the M1 Macs having changed some of the include paths which is really annoying but we will find a workaround as soon as we get a good bug report. We can patch that as well. Other than that the usual `listpays` integration, I’ve been paddling back from my idea of generating the groups randomly and I will now reintroduce group 0 as the first one we try, group 1 is the second one and group 2 is the third one. Just to re-add some logic to that, the randomly assigned ones were weird to say the least. And some various bug fixes.

I had my university exams so I am mostly busy on that. I was watching Money Heist and then I saw the document agenda so I thought I should join today.

We fixed something for both Alpine and Open BSD today. They are running the latest version.

Excellent work, the fixes were really nice and I was able to merge them right away. Thanks for pinging me when the CI was redone. That helped getting me back working on CI.

I have been working on the DNS address descriptor type. At the last protocol development meeting there wasn’t time to talk about it but I think it is pretty easy and there won’t be big discussions anyway. If we want this I think it can be done. I implemented it already to a point where it runs on my local machine. I need to care for the edge cases, what I do for error handling and stuff. It is a little bit more complicated than I thought. The way we find out what addresses and interfaces we are listening on and what we are announcing is a bit complex. But it can be done and it works already. I think I will be submitting a PR in the next few days. 

I’m assuming you are not going to be able to autodetect these? You are going to have to bind addresses manually?

The idea was when it is just an announce string I add it to the list of things I announce without special checks. You can already put in hostnames when you enter your addresses. Localhost is the hostname, `getaddressinfo` resolves this but also it resolves other stuff. When I put in example.com it already tries to resolve the address of example.com and tries to announce it. What I need to do now is figure out what I take as the local address, what I announce, stuff like this. I think it is pretty straightforward but the change is bigger than I expected.

I think that is always the case.

We are getting ready for the next release candidate today. c-lightning is stable, I was working on the things like implementing the `hsm_secret` encryption and auto-unlock on start or even between restarts, put it into a logical form. We are testing a lot of other services and updating on the Raspiblitz, a new database format of the Electrum Server in Rust and obviously the new Bitcoin Core release. I have been busy with those that are not strictly c-lightning related.

You are running the hsm tool in a script or something like that? We are having some flakiness when it comes to the hsm tool and related tests. We wait for the prompt and it never completes. Have you noticed anything like that and if yes do you have a fix for it?

When I started to build this the hsm tool was a separate binary and now this is part of lightning-cli. Since I’ve changed to that I have not come across any problems.

I think it was mostly related to the hsm tool which for some reason hangs forever in our case.

It didn’t happen. We are using it mainly in bash scripts benefitting from the stdout things… The autounlock and the unlock works in a way in systemd, it pipes the password in. Small changes which were made possible in the previous release.

It is very flaky and it is really hard to debug because it happens about once in a thousand.

I think I know what it is. But I haven’t pushed it because I had no good way of testing it. I can fix it and see if it works. We are making the classic error of not looping either on stdout or stdin we assume that a write succeeds and is complete. That is usually true but it is worth fixing anyway and see if it cleans up the flakes that we are seeing. I did look at it a while ago but I didn’t push it. It is a bug but whether it is actually the cause of the flakiness, I am not sure. I’ll fix it, it is not going to make it worse.

Can I ask which method of the hsm tool is failing or not very reproducible?

Very not reproducible.

It is one of these very rare cases that crop up in CI. You end up swearing when it does, yet another hour of waiting for CI to complete.

I have spent way too long rewriting the onion message spec. We do onion messages and then Matt Corallo started implementing them for LDK and he made some really good points. One of the main points was that it is documented in 3 separate places so it would be good to make that coherent. I agree, it would be good. Importantly when we sent an onion message you could tell that someone was sending an onion message or a reply. This is bad, obviously we should make them the same. Even though it is gratuitous to have two layers of encryption when you are sending an onion message and it is unsolicited. That involved a rework of the spec. I chose to implement it as completely separate paths inside c-lightning because I don’t want to break the spec. I am supporting the obsolete version and the new version. For one release we will send both, the old and new, and accept both. Then we will throw away the old one, it is an experimental feature, we are not going to keep it backward compatible for long. But I didn’t want to break everyone’s offers and onion messages again for the release. That’s been a larger engineering effort than I had hoped. Now all messages are blinded, you blind the message even when you don’t need to, you now need a way of telling whether something uses a path that you handed out or not. You hand out these anonymous paths, a series of encrypted blobs that you can put in an onion and it will get to me. But I have to make sure that you don’t ever reuse that for something else because that would cause me to leak data. If I hand out a path for you to reply to and then 6 months later you use it to send me a message for something else, I need to make sure that I don’t respond to that because potentially I would leak information about my node at that point. It turns out that you need to put a secret in there, it is all a bit complicated. I’ve got that all working, I was literally on my way out the door making it work, I was running 5 minutes late. It finally worked yesterday and I haven’t touched it since. I am going to clean it up, it is a fairly big PR unfortunately, and then it will be easier to review. Now I’ve done that I can produce test vectors which was the other thing people were asking for. t-bast said that Thomas of ACINQ is also going to be working on offers so it would be nice to provide them with test vectors. The worse the documentation is the more important test vectors are and the documentation is pretty bad. Test vectors are important so we can all interoperate. Now that roadblock is cleared, I was determined to get that in for the release, I can go back to reviewing some more PRs. In particular Christian noted the web socket extension, the spec on that has changed. Originally it was a feature to say “Hey you can connect to me and speak web socket”. Everybody hated that so now it will be a new address type which says “Hey there is this alternate port that you can try to speak to me web socket”. For us we could use the same port number and adapt but the spec has changed so we will need to advertise that. That will clash with Michael’s address descriptor work of course. Not in a fatal way but just in a textual way, we are both editing the same code. We will see how that works. Michael, I think you chose a higher descriptor number than the web socket draft for your draft?

I just took the next free one, I didn’t know there would be a clash. Mine is number 5.

I will move mine to 6.

There is a problem to keep in mind. In order of deployment there is a rule with the address descriptor type that the first descriptor type that your implementation doesn’t understand you have to ignore all the rest. We have to choose which one is more important.

Yours is more important so we will do that. I will move mine out to 6. Nobody else is implementing web socket extensions except for me so that’s fine. I will bump it. That needs to be cleaned up. I am working on everything else that we need for the release. There are things that I’d love to implement but onion messages is the critical one that I really want to get in, the key one to get fixed in this release so that we can do interoperability testing with the others that are implementing it.

How do you solve it? Do you define an end of life? How do you know when to respond to a certain onion message?

In the end you put a secret inside the encrypted blob. If you decrypt it you check the secret, you go “This is one of my paths. This is a path that I handed out.” That secret is derived from your core secret, it is always the same. That way you can always tell, even if you’ve forgotten everything else, this is a path that you handed out once. Once you’ve got that you can make correct decisions. If someone is using an old path they are trying to probe, you don’t respond. It is also important the other way. If they don’t use a path and you expected them to you must respond either or you must respond in the same way you would if you had no idea what they were talking about. Inside c-lightning we provide completely independent hooks for these cases to make it easy for people to write code that is compliant. We have one hook that says “This is a message that came in on a path that we supplied and here’s the node ID that they thought they were speaking to.” And we have another one that says “This is an unsolicited message”. You really can’t confuse them, that’s the danger. You send me a hidden path and I go “I think this is Michael’s node, why don’t I try sending his node the reply directly and see if he responds? If he does then I know it was actually him sending this invoice request or whatever. You really have to do it both ways. The architecture is key to making sure that happens. That is now documented in the spec quite exhaustively, it tells you exactly what you are supposed to do here. It was a bigger lift than I was expecting. That twist at the end was unexpected. But it does mean we now have full support for the parts we need for blinded paths in offers. You should be able to have an offer which is anonymous as well. I am not sure that will actually get in this release, I would like it to but no promises. It would be a pretty cool feature to have. The other cool feature to have, you should be able to extend the path. At the moment I give you 3 blobs, I say “Put this in the onion” and you’ll get to me. You know it is 3 hops from wherever the entry point is. It is fairly trivial to add dummy ones, you just keep unwrapping it. As long as it still seems to be to you, you keep unwrapping it and you end up at the end. You can pad it so it will look like there is 5 hops but there are actually only 3. That would be a useful extension. At this point it is still a FIXME. I was just happy to get over the hump and get it implemented. I’m being cautious about what I’m committing to do next.

Definitely a good idea. And looking forward to the LDK compatibility, that is a big one.

vincenzopalazzo: I’m not making anything spectacular, some pull request review and also I am working on fixing the `make check` command. There is some checking inside the lightningd config file. We are checking the experimental features that are not documented yet. I don’t know whether to put a generic message “This is an experimental feature” and nothing else inside the doc or skipping it. 

That is a common issue that we configure the build to run one way and then certain features appear or disappear and `make check` fails. We probably should filter out the experimental ones for the doc checks since they were most likely not be checked and not be filled anyway.

We should either make sure they are all labelled “experimental” so we can grep them out or worst case not run that check if we are in experimental mode.

vincenzopalazzo: Or maybe put the field inside another JSON file. If all the experimental features are inside this file we skip and nothing else.

We’ll see, I’ll review your PR, it has been on my to do list.

vincenzopalazzo: Also I made a script inside `make`, a formatting scheme. The command will take all the JSON schema,  pass the jq tools and store inside the same file. If jq doesn’t make any change we are sure that the documentation is not generated anymore. I check that this doesn’t happen.

It is time to start the next tabs versus spaces war because jq can be configured to use tabs instead of spaces. Round one.

I think we should use jq in the default, I think it is spaces by default. I genuinely don’t care. If we have something in CI that checks that it is generated correctly I don’t care.

vincenzopalazzo: I only put the flag… I can remove it.

Implementer wins, if that is how you implemented it you get to decide. That is your power as the person who wrote the code.

The PR is 268 files changed.

But it is once off. I will review the PR, it is fine.

Most of them are actually just derived files that we blank out in the review panel.

vincenzopalazzo: It was four lines that I changed and nothing more. I think spaces wins because I am the spaces person. 

But more characters with spaces, think of all that wasted disk space just with white space.

But tabs is wasted horizontal space. It displays larger and I have to travel more space to do my reviews. We can get back to that, I don’t care that much. Don’t say that you haven’t done anything, the reviews are very much appreciated. They are far more important than many other tasks.

# Release progress

I will quickly go through the release progress. There are a couple of PRs that need some attention. Some of them are marked as drafts and we should decide whether we want to updraft them or keep them as drafts for the moment. Many of the ones that aren’t drafts I am trying to shepherd through CI so those should eventually be merged since they have already been ACKed by reviewers. In particular Rusty mentioned the web socket one, I always took that one as a joke. Should we really undraft and get it in there?

Yeah Aditya is using it. 

If we have users we should probably do that. For PR 4767 adding the counter variable to the Autodata, it is probably up to Rusty whether that is worth breaking the gcc…

It is a gcc extension which means that if you don’t have it your build will break, we won’t notice that your build is broken. In practice we are all clang and gcc anyway, clang also supports it as an extension. Maybe I am being overly pedantic here.

That stuff, if that would be fixed that would be great. I have stumbled upon that.

There are magic lines everywhere which says “This line is magic” or “Do not delete this line”. Every so often you have to delete this line because you need more magic. For those following along at home this is way more detail than you’ll ever need. We autogenerate some symbols for various things and we use it based on the line number in separate files. It is usually fine because they are static but some of our tests directly include the C files. If you include two C files that ended up using the same symbol, they are on the same line in separate files. There is a fix for this called `__counter` which is a gcc extension that lets you have an arbitrary variable in there. The other thing is to actually fix Autodata to be some kind of other generation pass. We can generate the Autodata using some kind of tool rather than using the horrible hack that we have at the moment. It puts it in an ELF section on supported platforms and on unsupported platforms that don’t support ELF like MacOS, in order to find our Autodata we open up the binary, we fork off a child and we start poking around trying to search for it. This means that you get segmentation faults regularly as we probe pointers and things. They end up as crash things, little crash turds sitting in the corner of your MacOS box. It freaks people out but they are actually deliberate. There is a reason we might want to rewrite.. Autodata is cool but we autogenerate a whole pile of stuff, we could autogenerate our Autodata stuff rather than using Autodata. This would solve this line problem once and for all rather than using the embedded Autodata generation stuff. It strikes me as something that might be nice to actually fix properly. A single line shell script could actually generate the Autodata. Since we’ve already crossed that rubicon in generating some of our code we could just use this same thing. I don’t know if anyone has strong opinions. I am happy to spend a day cleaning that up. Obviously it has bitten Michael.

gcc is cool.

We don’t have any compilers that are non gcc. Famous last words.

Can there be a fallback that you set that defines using `_line`?

That is what we do. Then you end up with a problem where it doesn’t build because you’ve got the line clash. You get exactly the same thing now only you don’t notice it. An end user who is building it with some weird compiler… I will apply that to Ccan as the lesser evil perhaps. I will think about it harder and if I decide to rewrite Autodata then I’ll do that instead.

One more caveat, the Autodata also clashes horribly with Address Sanitizer because that’s a region of the binary that is not well instrumented by the Address Sanitizer. If it does instrument it then your offsets are wrong because it pads all the different locations to see if you are accessing a place where you don’t. I currently do have it blocked in my Address Sanitizer.

The answer here is that I should rework the Autodata stuff to use some kind of generation code. I will look at that this afternoon. 

But I really like Autodata.

Everyone does as long as they don’t read the code that implements it.

Trust me I tried and failed miserably.

# Adding more weight to larger channels, bias against Tor?

<https://github.com/ElementsProject/lightning/pull/4771>

Besides that we do have a couple of pending PRs that have reviews that need to be addressed. I think we have PR 4771 which is Rusty’s fix to add more weight to larger channels. I was intending to talk to Rene (Pickhardt) today but I forgot. I will have to reach out to him again since he has been running a couple of `paytest` instances. We might want to measure the impact of what happens here and how much difference it makes in the end.

I have been meaning to ping you about that. If we both run `paytest` we should be able to test against each other and get some stats before and after. 

Sounds good, I will install that one.

There are random numbers in that heuristic. I chose to make the size of the channel twice as important as the fees. Why? Because everyone likes the number 2. There are heuristics in there that I would like to actually validate before we deploy.

It also takes into account the size of the payment and the size of the channel. 

It is the ratio question. But it uses the actual fee of the channel and I wonder if it should use a nominal median fee as its benchmark for how much to penalize.

There could be an argument to accept paying more fees for more reliable or bigger channels.

That’s exactly the point here. To prefer larger channels even if they cost more, you end up choosing them just because the probability of them being able to transfer your payment is far superior than if it just fits through.

Along with other metrics I would add.

It is definitely not an argument that beats everything but from experience it looks like channel size is quite indicative of the range of capacity.

I think there is one parameter missing. I see the PR with capacity bias. Shouldn’t there be a parameter that is taking into account the current length of the route? The longer it gets the more important it is to go for bigger channels, something like this? With 1 hop I can just try but if it is 5 or 8 then maybe I need to bias more for this adjustment.

In the probabilistic model that Rene put together the success probability actually decreases exponentially with the length of the path. But it is a factor that we can add at a later point without incurring too much downside. For now let’s keep it as a one dimensional optimization problem and add the second dimension once we verify it actually works.

It is a heuristic that doesn’t cost you any more fees, it just saves you time. In practice what happens is we spend 27 attempts on all these stupid routes before we choose the obvious one.

When we leave out the length of the route which is a good idea because it would affect the routing algorithm quite dramatically, it has to know the number of hops before finding the route that is somehow stupid. Then we should put in an assumption that we assume a route to be 5 hops for example and put that in a static variable. We see on what assumptions we do this calculation.

We evaluate every hop independently, how much would it cost to route across this hop? That’s the only heuristic that we are tweaking.

If it is incremental then it would increase that as a parameter for the `getbias` function or however that is called.

But you can’t do that in Dijkstra because you don’t know the path length.

In Dijkstra that is not possible, yeah.

It is a heuristic and that is why I want to test that it does make some believable difference before we deploy it.

For the large amount of stupidly small channels it would make a difference. Maybe we also assume that the guys with the large channels are not using Tor?

That’s the other thing I want to address. I want to put that Tor fix in.

A Tor bias?

At least we already connect preferably now thanks to your work to non-Tor if we can. We should invert that if we are fully Tor. If we are an all Tor node then maybe we do want to connect to onion servers in preference. But that’s a win to start with. I think pinging is important because what happens is we find out that the Tor connection is dead at the point we try to make a payment. It is probably why it is so unreliable. Just pinging would find out earlier, the Tor connection would break and we’ll be forced to reconnect. That will improve our reliability in practice I believe. It won’t make it worse.

I have seen other scenarios, not Lightning related, where there were a lot of troubles. When a TCP connection is messed up I guess you know the best… 

You can always hang up and try again. That is usually the best way to deal with those things. If you are not getting any traffic you should just go round again. I am going to have to look through my logs to see what my Tor behavior is like, I haven’t been monitoring it closely. I have some Tor onion nodes that I connect to. I have heard reports that they are terrible but I haven’t zeroed in on them specifically. It would be nice to fix that. I think pinging Tor nodes, it won’t make things worse.

If your major objective is routing success and you are less concerned about privacy I would guess that yes you bias for larger channels, you bias for shorter routes, fewer hops, because every hop is a potential chance to fail. And you don’t use atomic multipath (AMP) (correction: multipath payments, MPP) unless it is absolutely necessary. Would that be a correct assessment if the only thing you are worried about is routing success and not privacy or something else?

We don’t implement AMP as Lightning Labs calls their version, we implement MPP. MPP is spec’ed, AMP isn’t. There is a clear trade-off. If you try to avoid MPP at all costs you might actually run out of time trying your best to have a single payment go through. And not have enough time to try splitting it if you prioritize single part payments over MPP. There is also an argument to be made about MPP actually helping you obfuscate your traffic quite nicely by chunking all your payments into common sizes. You aren’t telling anybody the complete size of your payment. Everybody just sees single parts that look like a single dollar. They are quite nicely intermixed especially once we get PTLCs where you can’t collate them anymore. This argument might actually benefit privacy rather than you trying a single payment giving away the entirety of the amount. And the amount might actually be of such a form that you are correlating yourself between hops. If I send 13 dollars and a bit and then I see something that is exactly 13 dollars the chances are this might be related. Whereas if I send out 13 one dollar payments and we can’t correlate them anymore then it is hard to track them. By splitting and using MPP we increase the chances of having a successful payment rather than you having to retry multiple times, failing attempts that are high privacy and therefore ending up with a stronger signal for somebody to pick up on. If I try 20 times in the matter of 5 minutes to pay a single invoice but always failing because my success probability is so low.

I think there is some magic triangle (e.g. [Zooko’s triangle](https://en.wikipedia.org/wiki/Zooko%27s_triangle)) where you have cheapness of route, performance and privacy. You can have maybe two of them but not all three. 

You might be located somewhere in the middle. Our point when setting up the randomness for the route selection was always that there should be an amount below which you just don’t care. That has been this 0.5 percent that we added where we are allowed to select a route on your behalf. If we go above 0.5 percent of the sent amount then we might reject and ask you “Are you ok if we try with a higher fee?” It is my and Rusty’s belief that if we make that allowable budget small enough then it really shouldn’t matter to you and you should be fine us randomizing in order to increase your privacy at a slightly higher cost. We’ve never been ones to try to squeeze every single satoshi out of the route finding at all.

There is a trade-off here. We don’t make it as cleverly as we could but there is at least a wave in that direction. For example the trivial example of padding the route at the end, that costs you extra fees and we pay it.

# Tor performance

Can I ask about Tor? The reasons for being against Tor, is it because of the broken circuits or is it because of the lag?

It is because in my opinion it damages the network health of the Lightning Network considerably already. The connections are not reliable enough. On a one hop basis that is ok, but not when you do 5 or 8 hops routing. A majority of those being Tor is a showstopper. I think a lot of users are doing, all implementations come with the Tor support, they just don’t care to get through the local firewall, their home routing network so they are reachable on the internet. Because of this they go with Tor and they think it is more privacy, which it is, but it is also unreliable. What we did is offer everyone the slowest possible solution to the problem everyone has. That is why it is damaging the network. I am not against Tor, I am pro offering ways to reduce that. 

A couple of comments. These are not only not getting through the local firewall but these are all home nodes. They are not renting a VPS, they would use clearnet. If someone is at home then they wouldn’t and shouldn’t put their money out in their window. It is reckless to run a clearnet node at home. The equipment you are using, it’ll be a Raspberry Pi if you are lucky in a stable hardware setup. A lot of times the instability is correlating with it being behind Tor but the reason might not be Tor, it might be a hardware issue or a flaky home internet connection or using WiFi.

That is on top, that doesn’t make it better.

The other thing is that lnd will in the next major release implement a feature that they will preferably communicate over clearnet. There is an option to switch this on, it is off by default. If you have a clearnet connection and you are reachable on clearnet you would go for that even if there is a Tor address configured. c-lightning has a couple more options regarding this but this is always a pain. A lot of people have dual connections. The Tor only nodes prefer the other Tor only nodes in terms of connecting to them because they can connect back to them. A lot of nodes prefer to have dual reachability. Most of them would only communicate through Tor. That would involve the exit nodes which are scarce. Two circuits when there should only be one. There is a lot to improve here, I appreciate that if you want more reliable payments then you go for a big VPS.

With c-lightning, we changed two weeks ago, we also connect to clearnet first. What we already talked about, I am adding DNS support to have dynamic DNS, a hostname that you can announce for your home WiFi usage so you don’t have to rely on Tor. If you want you can set up dynamic DNS and open the ports on your firewall and that would be working. Everyone could be a clearnet node if they want to.

It definitely has to be a conscious decision. In the end this is a performance metric that will fall out from testing and we will likely see people steer away from routing through intermediaries that are reachable through Tor only. And prefer going clearnet because they have the better forwarding profile. But for home users that are not intending to route remote payments it absolutely makes sense to obfuscate their location through Tor.

I totally agree, a normal user who just wants to spend some money or something that is totally the way to go.

It is not a decision that is up to us. We need to bubble that up to the user and allow them to make a conscious decision about which profile they fit more. If they are fine with advertising their clearnet address that is perfectly fine. Not everybody does.

I think the key here is that we’ve had a blind spot, we need to fix Tor performance. If we can fix Tor then that is a lot less of a problem.

Everyone would be thankful if c-lightning fixes Tor.

We already implemented Sphinx.

Importantly it requires some monitoring. I don’t know how bad this problem is because I have literally not been monitoring it. Relying on anecdotal data isn’t really going to help. I am going to be looking through my logs and trying to figure out what my disconnect rate, what my failure rate is on Tor nodes. Then after if we make a change to ping Tor nodes we can see if it improves.

Tor is already an onion network in of itself. After a certain amount of hops you are almost certain to fail. We put on this network another network that does the same thing. It just doesn’t like it.

Tor circuits are like 3-4 hops. That’s nothing. I know it adds to the probability of actually failing.

Tor users by definition are more like home users, as already mentioned those are the less reliable ones.

It is a DARPA project.

Core has I2P support. Maybe longer term I2P would be a slot in replacement for Tor. Apparently it is more robust although I have no idea who backs that up.

I have not read into I2P, maybe I should. 

It is much smaller for now so it is hard to tell what it does under the same kind of usage. 

That is good, less nodes that can fail! (Joke)

I had an interesting discovery regarding lnd but it is true for c-lightning as well. When you change the Tor configuration and restart the Tor process then the Tor port, the access port, would close and would not be reopened by a service that is unaware of it being closed, lnd or c-lightning. First we started to use dedicated Tor circuits for lnd but then we realized you don’t need to restart that aggressively. You can just reload. If you use systemd for example, then just reloading the Tor process wouldn’t stop the port being open but it would pick up the new configuration. That improved the reliability of my node for example. I’ve seen channels are dropping from the clearnet and Tor nodes and I didn’t know why. The incoming port was closed so even the Tor peers couldn’t reconnect in that case. It took some time to realize that. This is outside c-lightning but this is something we need to pay attention to.

Adding a regular ping, it would test the functionality of the link itself. But you are talking about the listening addresses, is that it?

Yes. You could ping that as well but that would be a circuit that goes out and then in. I have pinged that through a proxy or from another Tor circuit. It is a bit heavy to do it.

Testing an existing link is definitely in scope. Testing a listening socket might not be. We can probably see that on the issue tracker.

# Removing derived files

I know there are some strong opinions here. I personally am a bit bias against them simply because they tend to generate a surface for conflicts. It is something that is hard to get new contributors to pay attention to and it obfuscates the changes that are being done. But there are definitely good parts. For context some time ago we decided to take all of the generated files, those are files that are derived from specification. They build our transport and messaging system where we can take the Lightning specification and then we strip out all of the information that is not relevant to us. We generate the serialization and deserialization for messages right from the specification. We then have a system that takes the SQL statements that we have in lightningd and translates them into multiple versions and multiple dialects. For now that is SQLite and Postgres. Since they have tiny differences between them, a statement in one might not translate into the other, we have a translation layer that will take those and generate the various versions from it. We also do have a version that prints messages that we have and we generate a whole bunch of documentation files out of the Markdown files that we used for writing the documentation itself. That is very good. It means that if you checkout the master branch on GitHub you are left with a full source dump or a full source tree that you can feed into `make` and clang or gcc. You end up with a fully consistent snapshot of what is needed to build c-lightning. I don’t remember if it was related to the reproducibility thing but that might have been a thing where one computer generated something one way and the other one differently.

It was all about not needing Python to build. At the moment we don’t need Python to build and you don’t need Python Mako and Python Sphinx.

Sphinx has never been a dependency unless you build the documentation.

I was looking at how we turn our Markdown into man pages for example.

That’s Pandoc?

It was something horrific that pulls in a billion things.

It is MKRD.

That’s right. And some `sed` because MKRD is kind of buggy. If we are happy to go “You need Python and you need all the pieces” we can get rid of generated files. That’s mainly painful I guess for people on the Raspberry Pi but for everyone else it shouldn’t be too bad.

Would it be possible to make a script that prepares these generated files on desktop and then transfer the sources to Raspberry Pi? On the fast machine do the build with the generated files?

That is effectively what we do now. You could actually do a build on your fast machine. We should probably create a top level target for it.

How big is the impact? On your Raspberry Pi it is slow, do you have an idea?

It is more installing all the packages will probably take you half a hour. I’ll have to check. There is a lot of Python cr\*p. If you are running a modern thing you’ve probably got Python3 already so you won’t need Python itself but you’ll need Mako and a pile of other things. It will pull in quite a bit over a minimal build. On the other hand how do you often do you rebuild your c-lightning on your Raspberry Pi?

A lot? 

But it is a one time dev setup. 

We have all the checks and everything in there.

We compile about 40 minutes on a Raspberry Pi 4 with 4GB of RAM. What we do is we include the binary on the signed SD card image release.

That is with the canned derived files?

Yes. The Electrum Server, the RTL, things like that take a similar amount of time as well.

I can give you a script that deletes all the generated files and you can find out how long it takes… Michael has a nice Pi sitting there that he uses. I can give you a one liner that will delete all the generated files and you can see how long it takes to build just for comparison.

It is maintainer clean versus distclean. Start with a `make distclean` `configure` and then `make`. Measure the time it takes for `make`. Then do the same for maintainer clean. It tells you how much difference you have in compile time. It doesn’t tell you how much time it takes to install the dependencies of course. This is the one time setup I was talking about before.

What you say is valid for GNU autoconf packages, do we have distclean in c-lightning? Is it really the same thing?

It should be. I’m just checking our make files to see if we implemented it correctly. It looks like we have, it gets all the obvious things.

I remember like a year there was a PR that after `make distclean` not every generated file was cleaned. I think it is there.

Having the generated files in there, today, was really annoying. The channel type `printgen` and `wiregen` were not checked in and every single PR was regenerating them. Rebasing once we merged the channel type `printgen` and `wiregen` I had to manually rebase all of them, pick out all the conflicts. It is not a huge thing, it takes 30 seconds top to do that but doing that 15-20 times is still work. It is by no means a strong opinion, I just want to bring it up and see if there is clear consensus about what to do.

I have gotten used to it. I found it very disturbing at the beginning.

It is very clearly a trade-off of theoretical end users versus maintainers. I’m tempted to make maintainers’ life easier and give up on the experiment of checking in all the generated files. We could try to split the difference and ship the generated files in releases for example and not have it in Git.

In source tarballs that is?

Yes. Or have a release branch that has them generated in it. I don’t think it is worth it. We will break in subtle and undiscovered ways if we did that.

It should probably be added to the make tarball, what’s the script called? Build release tarball? That is the one where we bundle stuff up and that’s the source of truth for both the reproducible build and for the PPA at least. That would probably be a good idea. But it doesn’t really help users that checkout from GitHub and run it from there. Then we would have to tell them “Grab all this junk”.

Compile from Git, they are power users.

There are a lot of people able to do copy, paste. I was one of them.

vincenzopalazzo: Maybe it is possible to make a parallel branch autogenerated from GitHub Actions. We add another GitHub Action with the Python script that autogenerated the file and push to this parallel master. We fork the actual master and we have a clean master without the generated file. When we push on the clean master there is a GitHub Action that takes this master and creates a new one with all the files we need. The final user checkouts the autogen master branch, I think this is easier.

It sounds a lot like the Git flow where you have a develop and a release branch. You develop on the develop branch and merge into the release branch whenever you want to cut a release. The downside there is that the Git UI doesn’t allow you to set a default merge into branch and a default display branch. So we’d have to manually switch over. Either show the develop branch on GitHub, if you `git clone` the repository you’d still end up without the derived files. Or we would make the release branch the default one on GitHub at which point we only ever update the displayed version whenever we do a release. Every pull request we would have to select “Where do you want this to merge into? Develop, not the main branch.” It is a bit of a UI nightmare. I have worked with a company that has that Git flow and it just never ends.

We are trying in the Raspiblitz to do this, it is difficult. There are many outside contributors but it is two regular contributors at the moment. If you are ready to make the dev branch the default then that’s fine but otherwise you are breaking all the links, pointing to it from Twitter or whatever, you keep changing the version that is default.

But there is also another thing, the Git history gets polluted with all that stuff which is not meant to be in the repository. I have been working in a company which used Perforce, it is a commercial CDS and they had more than one terabyte in the history. It was full of binary blobs and things. It can be bad. It is not that bad yet…

My only experience with Perforce was at Google, it was horrible.

It is something to think about. We don’t have to make a decision. I just wanted to bring this up every once in a while to gauge where the interest is and once we all agree we can make the switch or not.

I am happy with both.

I would like to get rid of them, the generated files. I am timing builds with and without no so we’ll see.

Next meeting will be on the eve of release pretty much.

Last time we discussed Python dependencies, did that cleanly resolve in the last two weeks?

Yes and hence Christian’s thing, when we tag them we should automatically push up the updated Python packages from now. This avoids some of these tangles that we can get into. Or at least find out about them sooner. 

Trying to automate all the things.

vincenzopalazzo: We need to remember to not fix the version of the package because if we fix the version of the package on the requirements file we don’t solve the problem.

Be matching on the minor version not the patch level, which is the one we currently increment, and then we can bump that when we have a minor version. Semantic versioning is hard.

I will paste my build results on IRC.

Perfect. Thank you everyone for joining today.

