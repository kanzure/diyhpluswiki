Name: c-lightning developer call

Topic: Various topics

Location: Jitsi online

Date: October 18th 2021

Video: No video posted online

The conversation has been anonymized by default to protect the identities of the participants. Those who have expressed a preference for their comments to be attributed are attributed. If you were a participant and would like your comments to be attributed please get in touch.

# c-lightning v0.10.2 release

<https://medium.com/blockstream/c-lightning-v0-10-2-bitcoin-dust-consensus-rule-33e777d58657>

We are nominally past the release date. The nominal release date is usually the 10th of every second month. This time I’m release captain so I am the one who is to blame for any delays. In this case we have two more changes that we are going to apply for the release itself. One being the dust fix. If you’ve read two weeks ago there was an [announcement](https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003257.html) about a vulnerability in the specification itself. All implementations were affected. Now we are working on a mitigation. It turns out however that the mitigation that was proposed for the specification is overly complex and has some weird corner cases. We are actually discussing both internally and with the specification itself how to address this exactly. Rusty has a much cleaner solution. We are trying to figure out how we can have this simple dust fix and still be compatible with everybody else who already released theirs. The hot fix has been a bit messy here. Communication could have gone better. 

I have been trying to ignore the whole issue. I knew there was an issue, I was like “Everyone else will handle it” and I have learned my lesson. The spec fix doesn’t work in general. It was messy. When I read what they were actually doing, “No we can’t actually do that”. I proposed a much simpler fix. Unfortunately my timing was terrible, I should have done it a month ago. I apologize for that. I read Lisa’s PR and went back and read what the spec said, “Uh oh”.

The RFC thing didn’t get released until a few weeks ago. Our actual RFC patch wasn’t released until very recently.

There was a whole mailing list discussion I was ignoring too which I assume covered this.

It wasn’t quite the same.

The whole mailing list discussion, the details of how to address this were really hidden in there. I didn’t catch it either. I guess we are all to blame in this case. That aside, we are working on a fix and that is the second to last thing that we are going to merge for the release. The other one being the prioritization of the channels by their size. There Rene and I are finishing up our testing, thank you to everyone who is running the [paytest](https://github.com/lightningd/plugins/tree/master/paytest) plugin. We have been testing with 20,000 payments over the last couple of days. We are currently evaluating them. That will be the headline feature for the release [blog post](https://medium.com/blockstream/c-lightning-v0-10-2-bitcoin-dust-consensus-rule-33e777d58657) that I am going to write tomorrow. I have a meeting with Rene discussing the results and how to evaluate them and how to showcase what the actual improvements are. It is not always easy in randomized processes to show that there has been an improvement. There definitely has been so we have to come up with a good visualization of what that looks like. 

# Changing the timing for future meetings

We have been discussing this before, we might get to move this meeting a couple of hours. I think Rusty is already on summertime, southern hemisphere and Europe will be on winter time starting next Sunday. We could move it to 2 hours making it more palatable for us without cutting into Rusty’s already quite busy day work. If there is no opposition I would probably move the next meeting by 2 hours. Rusty will be one hour earlier and everybody else will be one hour earlier as well.

It will be 2 hours earlier when the time changes in Europe?

Yes but in UTC it will one hour earlier.

It is 19:00 UTC. 

The same time as the Lightning protocol meetings. They are 5 30am Adelaide time?

Protocol meetings are in Adelaide time but this one is in UTC.

We want to have different ones?

Now it will change and it will be the same time as the protocol meeting.

We can probably figure out how relative timezone shifts work out eventually. 

It is 19:00 UTC.

# Lightning Core dev meetings

With that difficulty out of the way let’s continue. Lisa and I have been at Core dev last week. We discussed a number of issues. One of the ones that we made some progress on, for me the big highlight was there has been some movement on RBF pinning. I think we understand the issue now much better and how we could resolve these kinds of deadlocks where part of the network sees one thing and the other part of the network sees something else. The issue being that there is no total order between transactions. There are two criteria, there is a fee rate and an absolute fee. They don’t always have a clear winner when comparing. You might end up with a network, one seeing the low fee rate but really big fee and the other one seeing the high fee rate but really low overall fee. That’s this eclipse attack that we have seen a couple of times before. For pinning that is really bad because you believe your transaction is going to confirm but in reality it is being blocked by a competing one that you haven’t seen yourself. We are looking into the details of how to solve that. There have been a couple of proposals. Gloria Zhao is working on these RBF policies especially when it comes to package relay. We are looking into how to solve that, still a couple of things to resolve but I am optimistic that we can come to a conclusion that works much better for Lightning. We also had the Lightning dev meetings where we discussed a couple of things among which is BOLT 12. BOLT 11 has been replaced at some point. We discussed how we could roll out eltoo eventually and what the issues are, various discussions about sighashes that could enable that kind of functionality. It has been a productive week. Sadly that has also slowed down our release cycle a bit. I could have probably done more there. We are still in good time for the release itself. Now I’ve realized that my notes would have been nice that I wrote up before this and forgot to save before restarting my Notebook.

# Individual updates

I worked on the onion message and now I will be working on the web proxy so I can send the message to a node on the network. I am mostly busy with that.

What is the web proxy onion message exactly? What are you doing there?

The onion message is BOLT 4. The web proxy, I send a message on behalf of the node on the network.

Are you sending onion messages over web proxy to a node?

Yeah eventually. This is the complete everything you need to do BOLT 12 from nothing in a web browser. Javascript that actually can speak the Lightning Network, he’s got that bit. He can speak to a node through a web socket proxy but the next step is to actually be able to construct an onion message to send through the Lightning Network in Javascript. That’s that whole other level, it is BOLT 4, onion message and all that as well. Unfortunately the web socket stuff did not make it into this release. I did update the spec. You need to use a third party web socket proxy. There are some. You can also create your own and c-lightning will ship with one as well that you can turn on if you want to speak web socket.

This means that you could have an app in your browser that could send onion messages to your c-lightning node?

Onion messages to anyone really.

We were talking about a descriptor for web sockets.

The onion message could end up going wherever on the Lightning Network. You could easily send it to a c-lightning node and forward it on.

I just added it to the milestones since we have a couple of changes still in flight we might as well get that one in. It has been in draft since I last saw it so I will review and merge it as soon as possible.

# Lightning Core dev meetings (cont.)

My updates from the meetings last week. We had an interesting discussion about channel jamming. We didn’t have any huge insights into how to fix it but there was a proposal to start changing the fees… There were two things there. There are two variables here. One of the problems with channel jamming is that there is a limit on how many HTLCs can be currently inflight on a channel, that is 483. The other problem is that right now every single HTLC that gets committed to a commitment transaction whether it is dust or not, a dust HTLC won’t actually show up in a transaction but the balance still gets updated. It still counts towards that 483 number. What this means in practice is that you could send very small 1 millisat payments and put them on for a very long time period, maybe 2 weeks of timeout. Put 483 of them through a channel, that channel would not be able to process anymore HTLCs. The amount of money that someone would have to commit to a channel and commit to this attack is very, very small. A couple of things that we looked at changing. One, is there a way that we can make the minimum amount of money someone pays to jam a channel higher, make it more expensive? Every payment attempt is kind of like a bond of Bitcoin you’ve committed to a channel at some point. In order to originate a payment you have to have locked Bitcoin in a channel that you’re pushing to a peer. If you look at that as like a bond or an expense to run this attack, if we can make the amount of money you have to commit to Bitcoin higher, make the attack more expensive. Even if you aren’t spending any money you are locking your own capital up for that long. Anything we can do to make that higher makes the attack more expensive. The other thing, is there any way we can make the number 483 larger so that in order to jam a channel you have to send more payments through at whatever rate, that also makes it more expensive. Then you have to commit more capital to a single channel to lock it up. Based off of these two knobs you can turn to make it more expensive to jam a channel, one suggestion was that we no longer count dust HTLCs towards this 483 number. That makes the total number of payments that are eligible to go through a channel larger. It also raises the amount of money that you need to commit in order to get one of those 483 slots. That makes it slightly more expensive. Another thing we looked at is there anything we can do to change the 483 number, make it bigger. I don’t think there are any concrete proposals on how to make it such that you could have larger than 483. I think there were some suggestions that maybe we have trees of HTLCs that you have buckets for. Another suggestion was that maybe there are bands of how big a HTLC you have to have in order to use up certain bands of that capacity. Dust has its own bucket of how many HTLCs you can put through it before it gets jammed and then larger bands. You stop being able to use it based on the amount of HTLC that it is consuming. The other suggestion was to make payments more expensive in terms of capital locked up in them by adding a variable to the fee calculation for a route that puts a dollar value so to speak on the HTLC lockup time. It would cost more to lock up a payment amount for a longer period of time. The CLTV diff of the payment, we add a factor that you multiply by when you are calculating a fee for a payment. That is added at every hop, a percentage of that fee. This makes it more expensive to lock up capital for longer periods of time. The ACINQ team had some pushback because people were paying more money for safer payments. I think there is definitely a longer discussion to be had there on the trade-offs for adding that. I thought it was interesting because we also have this HODL invoice thing that we’re trying to disincentivize. If you add an actual cost to that length that you allow people to lock up capital for, if the payment fails you don’t actually pay it but at least have them commit their capital and lock up a little bit more when they attempt it. Making it more expensive for a longer lockup period. It is something worth considering to make those attacks more expensive. 

# Individual updates (cont.)

Pinning stuff was interesting, I had an interesting chat about descriptors, just an overview of the state of multisig composition, not really related to Lightning. I’ve been working on the HTLC dust thing, it sounds like we are going to have some changes. There are two interesting things that happened recently. One is that someone’s database went down and they lost all their USB stuff. They had a problem, one of the channels was one where I had done a liquidity lease ad to their node, I had paid them for some capital. If this happens to you and your node goes down, there is a HSM tool called `guess_to_remote` that I believe darosior wrote that will provided you know what your output is on the unilateral close transaction that your peer commits to chain, if you have the `hsm_secret` it will attempt to guess what your spending key is. The script wasn’t updated for anchor outputs or for liquidity ads. It wasn’t working for the channel that I had with this guy. The reason it wasn’t working, all dual funded channels use anchor outputs, it is the most likely that you will use anchor outputs on c-lightning today. Anchor outputs changed what our `to_remote` script from a P2WPKH to a P2WSH, the hashes weren’t matching. We were looking for a pubkey but we should be looking for a witness script. If it has been leased, if the person who closes the channel has leased funds to the person who does a unilateral close there is an extra thing we need to grind for, how much time was left in the lease. I have a patch to fix this, I just need to test it to make sure it is working as expected. I don’t know if it needs to be in this release, hopefully that will be up soon. Future work, I have got some very delayed stuff that I should have been working on. There is currently a bug, if you are dual funding a channel and your peer decides to RBF it there is a bug in the way that the acceptor side reselects UTXOs to go into that open transaction if you’ve committed funds to it. Successfully calling the RBF code for a dual fund open is very difficult right now, I need to get that fixed for next release. After that I had a good conversation with Christian last week about some stuff for accounting, getting an accounting plugin out. I managed to sketch out some nice updates to the architecture of how we’re doing events. I sat down and went through from first principles how I would do the accounting stuff now as opposed to a year and a half ago when I did it the first time. I think I am going to make some changes to the event structure, I am fairly certain very few people are using it. I don’t think it will be a huge breaking change. Luckily I think there is a version there, I’ll add a new version, the struct already has a version. Hopefully that will be for next release. I think I’m going to get a splicing proof of concept done. All the pieces there, the dual funding was a lot of heavy lifting, we’ve got a PR draft of it done. I spent some time this morning pulling in the draft stuff and the drafted messages. It looks like there is a couple of message definitions missing from the draft, it needs to be cleaned up. I don’t think it is going to be too much to get that done for the next release. 

That user who had his USB stick deleted, he was completely without a database, thanks to Lisa’s help he was able to recover 99 percent of his funds. That’s a huge win for us. We might be looking into formalizing those recovery steps and make it easier in future. Although we don’t want to encourage people too much to run all of their infrastructure off of a single USB stick.

LND do something called [static channel backups](https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md#off-chain-recovery), it is literally a list of everyone you have a channel with. Someone has written a tool so that every time you open or close a channel it updates this list and sends it to you on Telegram. LND has written a workflow where you give it the list of peers you have channels with and walks through a reconnection attempt with them which causes the other peer to do the channel closure. c-lightning will do this if you have an old version of your database and you start up from it. Since an old version of your database has a list of what channels you are connected to at the time of the snapshot, it will walk through a list of them, attempt to reconnect to them and then do the exact same thing as you would get with LND when you attempt to use your static channel backup. We don’t have as much tooling as the LND solution does. I think a lot of people don’t like that as much.

Someone lost a lot of money buying liquidity using c-lightning last week. There is an experimental feature that you can run, if you have experimental dual funding turned on which is liquidity ads, these are cool because they let you advertise how much money you want someone to pay you for you to put money into a channel when they open it with you. You can lease out your Bitcoin to a peer for a rate over like a month. Every lease is 4000 blocks long. Someone did not read the ad. In order to accept an ad, there is a command you can use on your gossip and it will print out all the ads that are there and their JSON objects. They tell you the base fee rate and a rate that you pay per basis point, per amount of capital that you add. In order to accept a rate you have to copy out a condensed form of this ad and put it in the command that you run to fund the channel. You have at least acknowledged that you’ve looked at the ad and have copied out a part of it when you go to take up the person’s offer of liquidity. Someone had done a couple of them, hadn’t been reading the ads and some enterprising c-lightning node runner decided that their base fee for making liquidity ads was going to be 0.1 Bitcoin. Someone copied the liquidity ad and sent it to the peer and paid them 0.1 Bitcoin as their base fee rate for accepting liquidity. They were upset when the liquidity ad pushed all my money to the other side. The nice thing about liquidity ads is your fee ends up being more inbound liquidity for you. It is quite an expensive way to get inbound liquidity but you can now use it as inbound liquidity. I don’t know if this guy managed to find the person who put this in, politely ask them to pay him back, push the money back over the channel. I suggested this. My warning is there are people who don’t read the ads. Maybe you should try setting up liquidity ads to see how much money you can make. The other side is if you are accepting a liquidity ad maybe you should read it. I have heard a rumor that one of the Lightning router service websites is adding a slider so you can look through all the nodes that are offering liquidity ads and figure out how much it will cost to take up each of those ads. Hopefully there will be a pretty UI and a third party tool for these soon. Exciting to see that people are using it even if they are getting hosed.

Thank you for spending time looking at the database optimizations, how to clean it up. I am running always the latest version so everything works. 

We are also looking into alternatives for the backup because the current backup code just takes a snapshot and applies incremental changes. That can grow over time. We’ve added compaction already and a smaller database overall is definitely something that we might be able to replicate in the backup as well.

vincenzopalazzo: I am working on some pull request review and also a small change to c-lightning. I am also working on a library that works with c-lightning.

I have undrafted the [DNS address descriptor PR](https://github.com/ElementsProject/lightning/pull/4829) and it can be reviewed now. I also started working on the announce remote address feature which I implemented in our code. There is another PR where your code now reports to the other side… respond to a connection what the remote IP was. Now we can decide what to do when we get this information. Proposals please. There were some discussions already on just sending every remote address, unless it is a private network obviously, and announce it up to a certain limit. No checks at all because it is not so problematic to announce a few incorrect addresses. Different options are to wait for a number of same responses or a threshold, a minimum amount of peers that are responding with the same remote address. Or even try stuff like making a connection to the address in order to check if it responds. That might not always work. 

I’m pretty sure my router doesn’t allow me to connect from inside of the network to the NAT address. I won’t be the only one. To reiterate the issues that there might be, what we want to avoid is trusting a peer on what address they see us as and then announcing that. It may lead to connection delays if they told us a lie. It is not a security issue because the connections are authenticated and we make sure that we are talking to the node that we expect to be talking to. It is only an attempt to avoid some sort of denial of service attack where I tell you “You are this node in China” and this node in China doesn’t actually run a c-lightning node.

You can report addresses like the FBI’s address and then your node is starting to make connections to the FBI address?

No it is I tell you that you are the FBI.

We had this DNS stuff, when you have a lot of channels, a lot of peers, and somehow you are tricked into believing a different address and you announce that. A lot of people are now making a connection attempt there.

If it is a black holed IP then that can lead to considerable delays. If it is a reachable IP address then it will fail after a couple of seconds. 

For black holed IP how is it delayed?

For black holed IPs you are sending a SYN packet that never ever gets a reply. Whereas if there is some device at the end of the IP address then you get a FIN packet right away. It is one round trip to discover that there is nothing there. If it is black holed it may hang for several minutes. Depending on your kernel settings. I think it is a minute by default on most modern Linux kernels. 

Should we check that? Is it reasonable to wait that long?

If you open a connection to somewhere it spawns a separate openingd process that can hang forever and doesn’t interfere with the rest of the operation. It is not really that much of an issue, it is only when you count on being able to contact that node. I wouldn’t add too much complexity to prevent this. 

If you have multiple addresses launch 3 openingd and wait for the first one?

Sort of. We only ever allow one.

I think I would wait for 3 nodes to announce the same address or 10 percent or something like this and then just announce it.

There is also interference with the command line option. If we set a hostname via the command line options that should always stick around and not be replaced by whatever our peers tell us. I guess you’ve probably thought about that already.

I am very happy with the current address setting for c-lightning. I am happy to set the exact IP address and I can use ways to figure out my IP address very easily when it changes. I was doing some tests at home and it took me 3 minutes when I restarted a DSL router to announce the new IP address. The time was the DSL connection initiation. Immediately when the internet works I check what’s my IP address and then announce my correct IP address. This requires restarting lightningd.

We should fix this. We need some background job that scans for change network configuration.

Or we can make a RPC. The current way of doing things is not going away. Your solution will definitely continue working. DNS is just useful for users that might not have that sort of access to their router or not have the right tools to get to it. DNS is definitely a nice usability feature for home users. If you want to do something more elaborate that will always be an option.

I like the idea of a RPC command for changing the address while the daemon is running. 

We need some dynamic way without stopping, that would be good.

If it is possible. I don’t know all the details.

Everything is possible. t-bast implemented one of the things on ACINQ. Since those are protocol dependent am I just testing with him then?

Yeah. The specification process is exactly as you described. We usually have a proposal, then we have two implementations to make sure everything is inside the proposal, everything is well laid out and we can build a second implementation based on the proposal. Once two or more implementations have cross verified that they speak the same protocol then we can merge it usually.

We don’t merge it earlier in our code? 

We could although it always has the risk that it might get changed before it gets merged. That is usually where we hide stuff behind the experimental flags. The web socket isn’t based on a RFC if I remember correctly. That’s exactly the risk that we have. Things might change based on the feedback that we get from other implementations. If we roll out the status quo we might end up in a situation where we have to change the stuff later on. Then we suddenly have two implementations that compete. We’ve had that with the onion messages but for the DNS entries in the gossip messages, those stick around a bit longer so I’d like to move that after the milestone so that we don’t have a release that has a feature that is about to get into the specification and might have to slightly change. I don’t think it is going to change here but better to be safe than sorry in this case.

We have successfully released the Raspiblitz version which now includes c-lightning. We had a Twitter Spaces with Christian, that went well, the recording will be released. It was very focused on the c-lightning implementation. There are always small things here and there that can be improved, that is why we iterate. I have seen a couple of people using it so trying to collect as much feedback as possible. We have an update feature so when there is a new release from c-lightning it should be a smooth update within the Raspiblitz menu. It went as planned I think. I have been keeping an eye on the c-lightning Telegram channel. Regarding the backups, it is great that you can achieve the same restoring of the database but the database can be very large. You wouldn’t have that sent by an email or a quick sync to the server or even a Telegram bot. Given that people are used to it, if they switch to try out c-lightning they would want to have something similar there. 

That has been a huge release, thank you for inviting me to the Twitter Space. You have a busy Telegram chat.

It is like 1600 people. Some of them are technical so they come with suggestions or custom things that they have done. That is how we learn. A lot of them become contributors.

It is exactly that kind of feedback that we are looking for so that is awesome. I do think we can emulate the static channel backups quite easily by building some tooling around `guess_to_remote`. It is always a bit of a balance between making it too easy for users to skimp on stuff and not do what they should be doing. My hope is that by doing a similar tool we can have a belt and suspenders deal instead of going with a single belt.

I think the threat of force closing channels, especially during a higher fee environment, is enough to make people want to preserve their channel database. All the liquidity that they have built up if they are running a routing node, a lot to worry about. If there are recurring questions I try to update that [c-lightning FAQ](https://github.com/rootzoll/raspiblitz/blob/v1.7/FAQ.cl.md) on the Raspiblitz. There are a couple of things coming up there and will be extended. 

That’s excellent. Especially with the user that lost their full database, we definitely felt the need for static channel backups. By making it easier to run the backup plugin as well, less space, more efficient, less churn on the SD card or wherever you store that. We should also make it much easier for people to choose the right solution instead of the easy solution.

I wanted to ask about the [paytest plugin](https://github.com/lightningd/plugins/blob/6f2b8fb6374600f9e1e06e57884bde99d85383bf/paytest/README.org), it is trying to implement the Pickhardt payment?

Yes we do have a [pull request 4567](https://github.com/ElementsProject/lightning/pull/4567) which is a first step towards the Pickhardt payments idea of biasing towards using larger channels. That has in the model of that paper a higher probability of succeeding the payment. While we aren’t using the splitting strategy just yet we do already prioritize the channels according to Rene’s proposal. Like I mentioned before we are looking into evaluating that and if it works out that together with the optimal splitting strategy that Rene proposes we get even more we might end up implementing the entirety of that. The paytest plugin itself is a generic system to test how well performing our pay plugin is. What it does is it creates an invoice as if it were from the destination. If I want to test my reachability from me to you then you start the paytest plugin and I start the paytest plugin, I tell my paytest plugin to test a payment going to you. My paytest plugin creates an invoice as if it were coming from you and your paytest plugin will then receive incoming HTLCs and hold onto them for up to a minute. Then it reports back if the real payment would have succeeded or not. On the recipient side the only part that is needed is this holding on and collecting all of the pieces before letting them go again. Without that your node would immediately say “I don’t know what this is about” and tell me to shut up. This is generic and can be used for c-lightning now and I am hoping that lnd and eclair might be offering a similar facility eventually so that we can get a larger view of what the reachability and performance looks like in the network. We will use that going forward to experiment with the parameterization of our pay plugin and different mechanisms of splitting and prioritizing channels and all that kind of stuff. This is the first step but running a paytest plugin will help us make incremental changes in the future. There is also discussion on how to measure this stuff and what kind of bias we should be using. It is a very interesting discussion.

Last week I opened the [PR](https://github.com/ElementsProject/lightning/pull/4862) for GraphQL and got lots of great review comments on that. This week I am working on implementing those changes. I was also following the c-lightning chat and I was almost getting angry seeing some of the negative comments. It made me want to multiply my efforts to fix some of these issues, legitimate things that are hanging people up. c-lightning is a great project and deserves a lot of attention. I am happy to be able to learn a little bit more and hopefully to contribute more as time goes on.

What are you referring to on the negative comments? You mean on IRC?

In the Telegram chat, on the database topic mainly. Basically reports on platforms that were moving off of c-lightning in favor of LND and things like that.

Most people are moving from c-lightning to ACINQ because they came from LND to c-lightning being frustrated. We do have a couple of people in the channel that got burnt badly in the past. There is a certain resentment, it is something that I keep in mind whenever I read those stories. We try to do our best but we can’t do everything.

I made a short script which gets you an invoice when you have LNURL text. I was missing this, we don’t support LNURL but sometimes people communicate this to get payments. It is very easy, I will be happy to share and help if anyone has questions on how to get an invoice from LNURL.

We are getting a couple of proposals that are sort of competing, some are complementary. We will probably end up supporting everything and nothing. Having a way to bridge from one standard to the other is definitely something that is very much valuable.

If you know the [LNBits](https://github.com/lnbits/lnbits-legend) project which is kind of accounting software that allows you to create multiple accounts on top of a funding source. The funding source could be c-lightning, it would be a next step to get it into the Raspiblitz because we already have LNBits on LND. That has a lot of full scale LNURL support with a plugin system. LNURL is probably something higher level than something that would need to be plugged into the protocol or the base layer. 

I also got into contact with one of the authors of LNBits looking for help to get full hosted channels working. This would extend this accounting feature to also include keysends which as far as I understood are currently not possible with today’s LNBits. LNBits basically differentiates who the recipient of an incoming payment is based on who created the invoice that got paid. With full hosted channel support we could have virtual nodes really be part of a c-lightning node. Then you could run a single c-lightning node for your friends and family. This reminds me I still need to set up an appointment with the author.

fiatjaf is a big contributor to LNBits and it is Ben Arc who started it, there are a couple of others who are working on it.

# Full RBF in Core

One of the discussions at the Core dev meeting was on getting [full RBF](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019074.html) in Core. This is obviously going to be challenging because some businesses, I’m not sure how many, do use zero confirmation transactions. Thoughts on how important this would be for the Lightning protocol to get full RBF in Core?

We are already moving towards RBF on Lightning with the dual funded channel proposal. All those transactions that we create are RBFable. I feel like the question you are asking, not explicitly, is the zero conf channel proposal which is currently spec’ed. We didn’t talk about it but full RBF would interact quite poorly with zero conf channels. RBF means that any transaction that gets published to the mempool can then be replaced before it is mined in a block. Zero conf kind of assumes that whatever transaction you publish to the mempool will end up in a block. There is tension there. I don’t think there is an easy answer to that other than maybe zero conf channels aren’t really meant for general consumption. The general idea with zero conf in general is that it is between two semi trusted parties. I don’t think that’s a great answer but I think there is definitely a serious concern there where zero conf channels are concerned.

I was speaking to someone at ACINQ and they said they do use zero conf channels but there is no risk because all the funds are on the side of the party who could possibly cheat. I don’t know about other businesses who use zero conf channels.

Breez uses it. The logic is whoever opens the channel would have change from the opening transaction and would be able to send a CPFP to have it confirmed.

Now I’m thinking about it, any opening transaction, at this point there is only funds from one side. Only one side would be eligible to RBF it. You would only need to worry about it when two parties fund it. The dual funded channel would be the place where you worried about the counterparty RBFing you. Currently those are RBFable anyway. Having RBF everywhere wouldn’t be a new consideration, at least on channel opening. There might be other places where RBF is a problem, maybe on closes?

I guess dual funding is also not really an issue because in dual funding you would have to have both parties collude to RBF themselves. They would know that they are RBFing and know the new alias. There really isn’t a risk of one party providing funds and then the other party RBFing it without telling the first one. We end up with a wrong funding transaction ID which has happened a couple of times in the past when people were using the PSBTs and RBF bumping those.

That is not totally true because you could RBF an open and create a different transaction that is not an open transaction with the same input. It is not that they would RBF it and make a new open channel but if they RBF it and use it elsewhere and you have already been using that channel. It gets replaced by a channel that is unrelated, then you’re in trouble right?

If you use the channel before it is confirmed that is true of course.

A channel is opened to you, you receive a payment and then the channel is gone. Your received payment is gone.

Zero conf channels are a pretty specific use case anyway that does require a certain amount of trust. Definitely don’t run everything on zero conf.

Not the suggested default policy.

For example RBF would be really useful for [Greenlight](https://blockstream.com/2021/07/21/en-greenlight-by-blockstream-lightning-made-easy/). We have the routing node and we have the user node. If the user node was to try to mess with our zero conf channels we can prevent them from doing that. The API doesn’t allow that so we are safe on that side. We would forward payments but we would have the ability to track that much more closely than any node. We are basically rebuilding the ACINQ model here.

I need to understand how Breez how uses it. It is weird with policy because obviously someone could just make a different version of Core and change the RBF policy in that version. There’s that consideration. There’s also the consideration that the vast majority of nodes on the network are Core so how much of a security guarantee is that if you flip a large percentage of the network to do full RBF rather than opt in RBF.

Full RBF is definitely what miners might choose. The idea is that we want to keep that gentleman’s agreement as long as possible because there are users that rely on it. But eventually we might end up using it because miners will ask for it. Hopefully we can inform users in time to move away from a trust model that was not incentive aligned so to speak.

RBF is really good for miners because it gives people the opportunity to bid more on their transactions. If transaction fees start going up then everyone all of a sudden has the ability to start bidding more for block space. Where before they didn’t have that opportunity, you’d have had to add more bytes with CPFP. I am RBF bullish.

CPFP leads to a situation where the mempool is clogged and that would help the miners even more. I bet the miners like RBF less. 

Sort of.

It is more optimal than just creating more transactions with higher fees.

The average fee rate is still going to be that and having less throughput is definitely bad news for miners because it might be seen as an ecosystem weakness. Whether they are rational and take all things into account that is a different story I guess. From a user side RBF is definitely something that we want because it allows us to allow lowball fees initially and as we learn more about the mempool and how full the blocks were over the last couple of minutes we can fee bump. We don’t have to guesstimate where the fee might be in a couple of hours so that we can get it confirmed. We can start low and move up. It takes a lot of guess work out of the transaction confirmations. And makes a fair fee market as well. Price discovery. 

You can’t have c-lightning updating the Bitcoin Core client to opt into RBF? They would have to do that manually?

I don’t even know if there is a flag to enable full RBF in Bitcoin Core as of now. Is there?

You can opt in to using it.

Right now you wouldn’t want to RBF your channel opens at all. Don’t RBF your channel opens right now. If you are in dual funded channels you can RBF to your heart’s content, it is part of the protocol. Just make sure you are going through the actual RPC commands to make it happen and you are fine. On normal v1 channel opens you can’t RBF it because part of the open is that you tell your peer what the transaction ID they should be looking for is and RBF changes the txid. All your commitments to your transaction will be invalid so any money you’ve committed to that channel will be lost forever. So don’t RBF channel opens now even if you can do it. It is not a good thing to do.

All channel opens are RBF enabled, as far as I know, LND for sure. 

But you should definitely not use it.

There has been a red letter warning to not RBF any opens, absolutely.

Now I’m thinking about it it is probably best policy to make it by default the transactions or wallet builds are not RBFable. That is hard because of the way stuff is constructed. Probably the best policy when you are building an open transaction, if it is a v1 open make it not RBFable. By default all the v2 ones are.

Dual funding is safe for RBF. We should get that merged sometime into the spec.

It is only safe because when you redo the dual funding thing you and your peer both update your commitment transaction. There is a part where you do the commitment transaction by sig exchange on the RBF transaction that you built. That is why it is safe. You update your expectations for commit sigs. This is how you get your money out of a 2-of-2 funding transaction. You have to update your commitment sigs.

When we finally get dual funding merged and out of experimental, since single funding is the trivial way of dual funding is dual funding replacing the single funding? Or a RPC command that uses the dual funding code with an option that this is actually single funding?

By default if both peers are signaling that they support the v2 channel opens every open goes through the v2 thing. Right now you use `fundchannel` and depending on what your peer supports it either uses the current v1 protocol or the v2 protocol. It transparently upgrades you so to speak. When you go through the v2 transaction thing the other side might opt not to include inputs and outputs in which case the transaction you build will be the same as if it was through the v1 stuff. 

What is v1 referring to?

Dual funding is the technical name, the v2 channel establishment protocol. Right now when you establish a channel there is a series of messages that you and your peer exchange. When we are moving to v2 we’ve changed what messages we exchange and the order that they happen in and the content of the messages. The end result is that you end up with a channel which is the same as the v1 set of messages. The only difference is that in the v2 your peer has the option to also contribute inputs and outputs to the funding transaction. This is what enables you to do liquidity leases or liquidity ads because they now have the option to also add funds to the transaction. 

Dual funding is considered v2 rather than this is the second version of dual funding.

That’s right. Dual funding is possible on the v2 protocol. 

The v1 code will stay around for a very long time.

The idea is that if every node is supporting v2 then we would take the v1 code out. But that requires every node on the network to support v2 at which point we could remove v1.

Quite a while.

But you can never be sure?

I think we would be breaking compatibility to new very old nodes.

We have finished a Chaincode seminar, Bitcoin protocol development last week. Generally what I got from it is we don’t do such things in Bitcoin. We don’t do backward incompatible changes. 

That’s one of the advantages of not having a global consensus like Bitcoin does. We are able to do quick iterations with breaking changes without endangering the security of everybody. The difference between Bitcoin onchain and offchain is exactly that Bitcoin requires us to have quasi perfect backwards compatibility because otherwise we are breaking other implementations and we are introducing the risk of having an error in the consensus itself which would result in part of the network hard forking off. That is obviously bad and that is why there is mostly one implementation for Bitcoin itself. At least for the consensus critical part it is good to have consistent behavior even if that is sometimes wrong. Like it has been for CHECKMULTISIG. In offchain protocols we are dealing with peer-to-peer communication where we can agree on speaking a completely different protocol without breaking anyone else in the network. We have brought back that flexibility to do quick iteration, experimental stuff and deprecate stuff that we no longer require exactly because we move away from having a global consistent consensus. Now we are more peer-to-peer based.

Can you know what our nodes are running on Lightning Network?

Yes. Those features are announced in the node announcement. We therefore know what part of the public network at least is speaking what sort of extensions. Once the number of nodes in the network that speak only v1 drops below 1 percent we can be reasonably sure that we will not encounter any nodes that don’t speak the v2 protocol.

Is there any chance of congestion in gossip if there are thousands of nodes around the world? It seems like everyone knows everything?

The issue of congested gossip is definitely there. Ultimately we don’t want every node to announce, simply because they might not be online 24/7. We will see a separation into the different concerns. There will be nodes that are more routing focused, those will announce their availability and their channels. There will be a large cloud of users that are not stable enough to route or value their privacy and therefore don’t announce this kind of information to the wider world. Ultimately we think that this sort of relationship between public nodes available for routing and private or unannounced nodes that are consuming the routing services of others will not announce. Currently almost everybody is announcing. 

I think the Phoenix and mobile wallets are not announcing?

Exactly. That’s also why whenever we do a census of what everybody is running, we had a paper a couple of months ago from the University of Vienna that I co-wrote, that always specifies that we are only looking at the public part of the network. We do have some ways of finding traces onchain about channels that might have existed but there is no way for us to attribute that to a specific implementation. Whenever we do a measurement about what part of the network runs which implementation we need to be very careful about saying “This is just the announced part”. We can reasonably believe that it is representative for the kind of features we have. Especially for ACINQ they have more visibility into what version a node is using.

