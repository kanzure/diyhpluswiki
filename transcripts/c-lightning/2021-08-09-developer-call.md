Name: c-lightning developer call

Topic: Various topics

Location: Jitsi online

Date: August 9th 2021

Video: No video posted online

The conversation has been anonymized by default to protect the identities of the participants. Those who have expressed a preference for their comments to be attributed are attributed. If you were a participant and would like your comments to be attributed please get in touch.

# Individual updates

Today I started to review some pull requests. I also finished my first draft of the paid order of the metrics plugin. I have a paid order make a chart. On [lnprototest](https://github.com/rustyrussell/lnprototest) I think we can remove the Postgres dependence but I haven’t tested it and I need to work around it.

That would be good, it is an indirect dependency so it would be good to get rid of it.

On Raspiblitz there will be a release candidate which will include a c-lightning option to be able to run and test everything in more detail. Others have been doing work at the BTC Citadel in Germany which was good, that’s what I heard. We’ve been doing work with Tor, the censorship resistance aspect of the node which will include a menu and some scripts to aid using bridges, vanguards and authentications. This might be handy especially in view of what is going on in the regulatory side in the US now. The plan is coming together, we are starting to test and we hope we will releasing something usable soon.

Someone opened a zero fee mega channel to me, I was very happy with that. There is already a movement for zero fee routing.

Is that zero base fee or zero total fee?

Both. Zero, zero.

Is that good?

My node is operating on that for months now, even before there was any movement.

A race to bottom, I don’t know if it is good.

It helps with channel rebalancing, if you have many peers who are zero, zero. You can rebalance for nothing. I only have one zero fee channel. Of course my channels are routing zero fee but it is one way. The other way they have some fees.

Rene (Pickhardt) was excited for a while before he got excited about the routing stuff, having this local gossip, you would offer discounts to people in a localized way and say “I wouldn’t mind rebalancing so if you are up for it I will give you a freebie through this channel this way.” If you get enough of them you could rebalance, if everybody agreed. He never quite sketched out exactly how that would work. It was a cool idea. How would you identify the particular payment that was going through. There is a whole heap of questions. I always thought it was a cool protocol, you could just opportunistically gossip if you are kind of unbalanced, not ridiculously but a little bit, give people a chance. Rather than blasting out the whole network all the time that your fees are going up and down, you could do this local thing.

We will see long term.

I look forward to seeing your results. I ran zero fee for a while because I wanted to get traffic just to test. But if everyone does it then that is going to suck. I will have to start paying people to send. We are going to go back to negative fees aren’t we?

Long term you would expect the fee to be non-zero but small. As you say it is a race to the bottom unless some big routing nodes are going to offer it as a loss leader because they want data or customer interaction.

It is a data sell. I am a little more comfortable with a network where people are charging reasonable fees to operate their nodes than I am to think they’ve got some side hustle. If zero fee nodes are run by the NSA I’m not particularly fond of that idea. But on the other hand if everyone is running a zero fee node maybe there is no profit to be had? I don’t know.

My zero fee node would be running anyway. It is a home router and SSH server and so on. It would be running anyway with my Bitcoin node.

There is a theoretical cost in having your hot wallet exposed. I host on Digital Ocean and I have not made enough money back to pay for my hosting, even close. But I open things at random so I’m a terrible node operator. I know people are out there tweaking and getting into it which is fantastic because all their effort pays off in more liquidity for everyone else but I am not that guy. I let Z-man run [CLBOSS](https://github.com/ZmnSCPxj/clboss) on my node and I don’t even know what it is doing. It is doing stuff, I see it doing a whole heap of things. It did this massive onchain payment at one stage. “What the hell was that? Did you just steal all my money?” Apparently it decided there was too much in one channel and it was going to loop out. It runs my node, I don’t know, it seems to be working.

I have generated the Javascript for different functions. I have tested them against the standard TLVs, hopefully I will initialize them tomorrow and all things will work for the test vectors.

I have a PR for you to pull the test vectors out from the Python code. I am writing a parallel version in Python, ideally we will share test vectors. Some of them are from the spec. I started pulling in the spec as an external module so there is a PR coming your way that makes it a little bit easier to share all that data which is nice. I think everyone is looking forward to the npm, that’ll be cool.

I am working on adding [offer](https://bolt12.org/) support on c-lightning REST and then planning to add experimental offers functionality on the [RTL](https://github.com/Ride-The-Lightning/RTL) UI as well. Thinking through the UX and the different scenarios on how to handle offers, both generate offers and if somebody pays an offer how to set up a recurring payment, what type of UX. I’m working on the backend right now, c-lightning REST and then figuring out an experimental UI for offers. 

Interestingly Nadav (shesek) is working on integrating with [Spark](https://github.com/shesek/spark-wallet). He’s hit the same kind of problems. His initial release which will come out soon, he is waiting for the final c-lightning release, when that comes out it won’t support recurrence. All the big UX questions are around the recurrence stuff. He is going to have the basic offers and he is hoping in the next release he will get recurrence. It requires local storage, have timers and things like that that are a whole new set of UX challenges. Obviously that is what everyone wants.

RTL does not have a database. To support recurring payments for offers we have to create a database and create a program which will wake up, look up the outstanding offers to be paid and then go back to sleep. This kind of logic will be completely new in RTL to handle this.

He is wrestling with the same thing. We have a [datastore plugin](https://github.com/ElementsProject/lightning/pull/4674) now for c-lightning that is going to be built in in future, there is a plugin for older versions. It is just a key, value store for plugins to use. In particular Spark will be using it for storing the recurring payments. It would be nice to have that standardized so that whatever front end you were using would use the same thing. It is still very early days. I have implemented the plugin for the datastore and I have implemented the API as a pull request, it will be in the next release. The key is a list so it is a slightly structured key, it is a JSON list, you can have levels effectively, a hierarchy. But very simple functionality, replace, append, atomic replace and list. It was a compromise, I don’t want to store everything but a lot of plugins want data. The [summary plugin](https://github.com/lightningd/plugins/tree/master/summary) even, it keeps uptime data. They are all stashing it in their little databases. It is nice to have it in one so you can take that database with you and migrate. You don’t want to have to go “If you are using this plugin you also have to pull this other file”. Standardizing how we store that information is definitely something that I would like. I will start an email chain with the three of us at least on that.

I am hoping to keep my finger on the pulse of what is happening for c-lightning. I think long term I am looking at hosting some liquidity ads and maybe create a more custodial solution until the protocol is ready for production. We can bootstrap that to create a UI for it.

# c-lightning v.0.10.1

Release: https://medium.com/blockstream/c-lightning-v0-10-1-eltoo-ethereum-layer-too-2e968a03ca83

We are getting the release out, there is a bug in the UTXO selection stuff that I have introduced. darosior put a [patch](https://github.com/ElementsProject/lightning/pull/4703) up for it yesterday. There was another thing that needs to be patched before we get the release out. That is currently in progress. The [changelog](https://github.com/ElementsProject/lightning/pull/4707) stuff is up, waiting for that to get through. It should be cut within the next couple of hours or so which is exciting. We’ve got an updated version of offers going out, the dual funding stuff has changed a little bit. I think the most exciting stuff in this release is probably going to be the new funder plugin. That’s cool because it finally lets you set up your node to provide liquidity to any incoming request provided that the other peer is doing dual funding. It has to be a c-lightning peer and it has to have experimental dual fund also turned on. With the last release we included the dual funding stuff but it didn’t actually include a plugin that would enable you to put money into any request to open a channel that used dual funding. My node for a long time was the only one that really did that. This release has a plugin that will make it possible for everyone to start putting funds in the other side of those dual funded opens. The more exciting and interesting thing is that the funder plugin is what will let you set your terms for that liquidity that you are now willing to put into open channel offers, which we are calling [liquidity ads](https://github.com/lightningnetwork/lightning-rfc/pull/878). I am working on a blog post today to explain how all that works, how you set it up, how you use it, how you take advantage of it, what all the commands are to make that work. That will be coming soon. It is hashtag reckless. In theory people will be paying you for any liquidity that you put into a channel in response to one of these advertisements that you are putting out. But it will be locked up for about 4000 blocks, which is roughly a month. The trade-off there is you get paid but you can’t move the money too far as long as it is leased.

Shall we list the caveats behind this?

The channel lease lock, if someone pushes the money out of the channel during the lock, the liquidity got used so whoever you were leasing that liquidity for was able to take advantage of it, able to move funds, had inbound capacity and then able to receive money. But then the lease is gone…push it to a different channel and you’ve got a lock for whatever is left in that channel for 4 months still.

There is the case where I give you a million sats of liquidity and then I immediately put a million sat payment through you. I’ve got my liquidity back. I’ve paid you for that and in a meta sense I have used that liquidity. That was not quite what you intended. You intended me to route for other people. There is refinement there, you should probably rate limit your HTLCs or cap the size of them. Say “I want you to do this in small pieces. I do not expect this liquidity to be used up all at once.” The other thing is that there is an escape hole in the lease. If I go onchain I have got this extra forced delay to hold it out for a month. Even if I close the channel immediately I don’t get my funds back for a month which is part of the deal. You paid me for a month. But HTLC outputs themselves are not encumbered by an extra timeout because that added a lot of complexity. If I push a giant HTLC and then I drop to chain and then the HTLC times out, I pull those funds out, I can get the funds back before a month which is the other reason to limit the size of HTLCs in flight at any one time. There is an escape hole there, it is not perfect. The thing I’m really excited about is liquidity ads, the contract is actually pretty good. I tell you exactly how much onchain weight you are going to have to pay for. When you come to me and say “I want liquidity” you are setting the fee. I say “This is how much it will cost you in bytes onchain.” Whatever your fee is you’ll be paying for that onchain weight. I estimate that upfront, maybe I assume I am going to add one input and maybe another change output. I take that into account. I also tell you the base plus percentage on the amount you want. But I also commit to the maximum fee that I will ever charge anyone else to use this channel. I give you a signature on that so that if I ever break that, I send a gossip ad out saying “My fees have jumped up within that one month period” you can show people this signed promise that I would never do that. That’s very soft enforced but it is kind of better than nothing. There is currently a model on liquidity where I give you these great rates on liquidity but then I screw people who are trying to use it. That’s ok as long as I’m transparent about it, as long as I tell you what I’m going to be charging other people to use it. You are paying for liquidity so that people can get liquidity to you. If I’m charging people 5 percent or something ridiculous on that liquidity I’m not actually providing you the service that you thought I was. Having transparency in the liquidity advertisement I think is incredibly important. At the end of the day you cannot force me to provide you liquidity. All you can do is force me to lock up my funds. I can just refuse to route anything. There is a small level of trust here. I think we are pretty comfortable with the parameters as done in the draft. I think it is pretty thorough. In an open marketplace transparency is very important, the fact that you tell them what rate you are going to be charging people to use that liquidity you are providing is incredibly key. The fact that you are actually blocked, the lease is real, it is not just a friendliness thing. Because it is decentralized you have to rely less on reputation although there will be some of that when you are choosing your peers, and more on onchain enforceability of these things. I think that is a key differentiator.

The other thing to note is the dual funding is incompatible with the dual funding from the previous release. We broke it. That’s life being in draft, that is why it is experimental. We also broke offers, offers are incompatible with the previous release. One, because we changed the spec and two, I had a bug in my Merkle tree implementation. It calculated the offer ID completely wrong, calculated the signatures completely wrong. That’s life on the edge. There are no guarantees, thank you Aditya who independently implemented my Merkle tree implementation in Javascript and found a bug in my test vectors but has validated that it is correct. I am more confident this time. That is an important note. This is experimental for a reason because it is still draft. Until it is nailed in the spec and completely finalized… I expect ACINQ to come along and implement dual funding at some point soon. They may well have some really good feedback as they’ve done previously and the spec may change. Obviously we try to bridge compatibility but if they come up with something that is genuinely better for something we will throw existing users under the bus to get the best final spec possible. That’s the experimental tag.

It is worth mentioning that the dual funding is it is only in the open protocol. Once you have the channel established all of that goes away anyway, it is just who is able to open channels to you using it. That being said, I am assuming most people will want to update to the latest release anyway since it is the one that finally enables you to start providing your own liquidity to peers. It has got the tooling for it now.

Does it require a closing of the dual funded channel? And then a reopening?

No. 

If you want them to give you liquidity and you already have a channel with them you would need to close your current channel and then have them reopen a channel where they put liquidity into it.

Yes, we only support a single live channel with a peer at the moment. That’s independent of anything else.

For future releases, when we have splicing in theory it might be possible to renegotiate something with a splice instead of a close and reopen. 

That’s the bit ACINQ really want, they want splicing really badly. Very excited about this release, recommended upgrade for everyone. It has been a long release cycle, much longer than normal. I am hoping the next one will be shorter.

I was curious about limiting the max HTLC size. Why would you want to do that? When I open channels it is so I can route as large HTLCs as possible. 

Because of the escape hole. If you pay me for liquidity and I use everything except the reserve, 99 percent of it, one huge HTLC. Then I drop it onchain unilaterally and the HTLC times out in 3 days. I can get that back in 3 days because the HTLCs are not encumbered with the lease timeout. Normally the deal is you’ve paid me for liquidity, I can’t get my money back for a month. But there is a hole and that is the HTLCs. If you limit the number of HTLCs in flight at one time you reduce the size of that hole that I can get back. Also using up all your liquidity simultaneously at once is not the real case you are going for usually. You probably want this liquidity to last some period of time. These days with MPP, even if they can only use part of the liquidity they can use something else as well. Usually you are opening more liquidity than you expect from a single payment although maybe you’re not. Maybe you are only after that one payment and that’s why you need the liquidity, in which case perhaps that’s fine. In that case you don’t care if they keep it for a month or not. The main reason is that the HTLC is not encumbered by the extra delay that you’ve agreed on on the lease.

What was the motivation for implementing offers so soon in Ride The Lightning? Was it Rusty’s advocacy or a particular feature of offers that you wanted?

I am interested in the improvement of the payment side of things and I was definitely interested in looking how the UX should be. I wanted to experiment. RTL and c-lightning has been low on functionality so I wanted to add more features, more functionality as well. Even though BOLT 12 is not ratified, it will be a feature exclusively for c-lightning users. But still I wanted to try out the UX, define and figure out how the offers should work, take a lead and figure out the UX on that.

I am incredibly grateful. I need people coming from that side looking at the spec while it is still in draft and going “This sucks” or “If you only added this it would be so much nicer” or “This is completely useless, let’s get rid of it in version 1.” There are things I didn’t put in the spec for example because at some point you go “There is a lot of stuff here and we have to cut”. That feedback is useful.

Will this be implemented through c-lightning REST?

Yes right now I am working on c-lightning REST. I am also waiting for the c-lightning release as well because I want to make sure everything works in the latest release. After the c-lightning REST update we will work on the RTL UX.

We will synchronize this with the Raspiblitz thing which will come out as well. We did the same with lnd, RTL was the UI to start with and there have been a lot of things grown out of it later on. It would be good to keep in touch about that.

# Reckless plugin manager

I am aiming for next release that we have [Reckless](https://github.com/darosior/reckless) installed as a first class citizen. Reckless is the plugin manager that darosior wrote. I had some discussions with him about bringing it in and making it formal. You will have Reckless install or Reckless upgrade, all the Reckless commands by default. It means it will be our first built in Python plugin which is an extra dependency I’m aware of. But I think it is time. There is so much cool stuff appearing in the plugin repository. I talked about the datastore functionality for example that people are going to want. There is [Commando](https://github.com/lightningd/plugins/pull/280) of course and other things I’ve been working on. The c-lightning REST API, all these things are things that increasingly people are going to want. It gets more complicated because people build things on top of other things. This plugin requests this other plugin. At the moment they have got to go to GitHub and be able to clone it and point things to the right path. It is one of those classic hurdles that we’re putting in place for anyone who is not a developer. If they just want to play with stuff it is really nice to have this Reckless install “Are you sure? This may steal all your money.” The ecosystem should just work. It is one of those classic “We should have done this 2 years ago but the second best time is now.” I am aiming for that for the next release, we’ll have Reckless as a first class citizen. People will be able to just install plugins. One of the reasons we have plugins is structural, to do with the way we run the c-lightning team. There is a handful of us and most of the interesting work happens at the plugin layer. We really want to enable that. People write a great plugin but then to get people to use it is a pain. Reckless will mean that those awesome plugins people are writing can become default. You can give them a command like `reckless install` all these things and pimp your node. I think it is one of those community enablement things that I’m looking forward to seeing what people do. The Reckless thing needs some work, it needs to pulled in and refined. That’s one of the things I am excited about for the next release.

Is that the only candidate plugin manager? There are no others?

It has got the best name. To be fair it has that name because I asked darosior to rename it to Reckless. There will be a significant rework in order to get it but it already has the basic stuff to do Python plugins, Go plugins. We can add some metadata. It is nice to have that base and people can add other plugins, figure out how to build them and what they need. It is nice to standardize on one basic one. I am happy for there to be a million but if we are going to include one let’s include the one that is most mature. That was the thinking. You can use that to install your favorite one if you want.

Use a plugin manager to install another plugin manager?

Absolutely. Plugins all the way down.

# Runes

The other thing I should mention is I was hoping this week to hand out a rune… [Commando](https://github.com/lightningd/plugins/pull/280) is this plugin that lets you communicate over the Lightning Network and feed commands to your node. I’ve added [rune](https://github.com/rustyrussell/runes) support which is basically a simplified version of [macaroons](https://research.google/pubs/pub41892/). I am hoping this week to tweet out a rune so people can get info on my mainnet node because why not? I will publish a rune that will allow anyone who is running Commando to query my node for status. I may also hand out runes for people who are on particular node IDs. You can look at what does your connection look like from my side. If you are already that node ID then you can ask what it looks like from my side. Probably on my testnet node I’d like to add a public rune so people can ask for invoices. Then they can do end to end testing with my testnet node if they want. They can make it mint an invoice for them or an offer until the database fills up. That is only on my testnet node because I don’t want them to…

Can they ask for a new address on your node and send onchain funds there? Make your node open a channel?

No. I could do that… The rune permission thing is command based, it is a single command. If you want a series of commands that you authorize in order you would have to write one plugin that does all those commands and then authorize that new command to be run. You can’t really just do it that way. You have to stop somewhere. Giving people more control over my testnet node would be a pretty cool thing to have.

Would it?

It is an experiment. The purpose of my test nodes is to learn the most I can out of the experience of losing money through c-lightning. This meets that goal.

I think when you mentioned the Commando thing you misspoke. You said over the Lightning Network but you mean by web hooks? It lets you control your node via web hook?

No. You connect as a Lightning client as a peer and you send this magic message that goes “Run this command”. It checks either the rune inside it or a whitelist and then it runs it and sends it back over the Lightning Network itself. You are thinking of the fact that I’ve also got a PR pending for the next release that if you connect and you are actually speaking web socket instead of native we speak web socket back to you. Between the two it means that in theory you can control your node entirely from Javascript. But in order to do that you are going to have to implement Noise NK over Javascript.

There’s a Python library?

You can do it in Python, yeah. But if you are using Python you don’t need web sockets, you can just use socket. If you really want to do it from your browser… Funnily enough this is on Aditya’s to do list after he’s finished the BOLT 12 basic stuff, implement Noise NK and why not implement onion messages as well?

Do it in Typescript, I’m kidding.

No. Then you can control your whole node from your browser which would be kind of cool. It is openoms’ fault, he was complaining about this matrix of all the different control possibilities. I went “They all kind of suck. You know what the world needs? Another one”. I don’t know if it is a good idea but it was definitely inspired by him talking about the possibilities there. And also shesek talking about the Spark problem, they have to get a Let’s Encrypt certificate and all this dance they have to do so you can connect to control your node. I was like “We already have this authenticated peer protocol, maybe we could use that.”

It kind of opens up a way that someone could have a hosted Ride The Lightning, you just come with your rune, you paste your rune in and then you can control your node from someone else’s hosted platform.

Yeah. Runes are kind of dangerous. For example the mistakes I’ve made include giving someone access to your logs while I was logging the master rune. That means they can read out the master rune secret because the datastore plugin was logging everything you wrote to the datastore. Of course the first thing it did is write “Here is the master rune we must keep secret” and it logged it. So if you had access to your logs you could bootstrap that and access your entire node which is dumb. What other mistakes have I made? I let them access everything that started with “list” or “get” which includes “get shared secret” which does the ECDH handshake. If you can do that you can use that to imitate my node and communicate as my node to anyone else. This permissions problem is generally hard. Giving people narrow permissions is much more useful than going “I will let you run this gamut of commands and see what happens.” Anything that touches the database in a non read-only potentially gives an ability to DOS you. Letting them mint invoices sounds pretty harmless… You could insist that the description starts with some particular string so you could tell which ones they’ve minted but they could fill your database. It sounds really cool but I think in practice it is limited to an all or nothing limit where you might give them the very specific time limited access to something. But we’ll see, the technology is out there, people will use it.

Is the intention of this to grant yourself access to be able to remotely manage your node or is it more for other people to be able to query your node for the data it has?

Both. You might as well use the same mechanism for both. You give yourself a master rune that does everything. The way I imagine Spark using it for example is it will print a QR out which is “Here is the node data and a rune that for the next 60 seconds lets you mint a master rune.” If that QR code leaks it is only useful for 60 seconds. But you would scan that into Spark and it would use that to connect to your node, authenticate and then add a rune that’s locked to its node ID, the Spark node ID. From then on it would be able to access everything. That’s an example of how we would see it used. In that case it would you authorizing yourself. But obviously it opens the door to having a read only version of that. You go “I am going to give read only access to this Spark on my disposable phone or whatever it is I don’t necessarily want broad access to.” As I pointed out read only access, I’d have to look through all our log messages. What sensitive data are we logging that you wouldn’t expect? Especially debug level logs, we log a lot of cr\*p. Obviously you are leaking privacy but what else are you leaking? There are still open questions on this. Hashtag reckless but it is kind of cool. And I blame roasbeef. At LN Conf he was like “You’ve got to implement macaroons, they’re so cool.” I was like “Really? They seem like something you don’t need.” But I can understand it now, having implemented it I’m like “I could do so much stuff. No one ever will but I could, I really could.”

Do you worry that we’ve implemented runes and lnd is macaroons, that will create some…

Good question. Other than the fact that macaroons are implemented the correct way I was really annoyed when I read the Google paper and realized they completely missed a trick on how to do this simpler. No it doesn’t because the trick with macaroons and runes is the same trick. You can give me a rune or macaroon and I can append conditions to it without talking to you again. That’s a really clever trick, don’t get me wrong. I can take a macaroon that accesses something else and give you one that does the same thing but only lasts for 60 seconds or can only access this subset, whatever. I can add restrictions without having to go back to the server and round again. That is a very cool technique that no one will use in practice. In practice everyone will take the string that they’re given, treat it like a cookie and hand it back to make commands. At that level they’re compatible, it is a string. You can hand the string back and you get to do the stuff. If you want to pull them apart and do clever things we were going to be incompatible anyway because the nature of the commands that you would authorize are different. At that point you’re like “What benefits are there from having compatibility?” Plus I like implementing things that are simple. It was a side project and it was fun. In practice people will just use them as cookies and it doesn’t matter whether it is lnd or whatever. You store them somewhere and you hand it back to authorize yourself to do things. Compatibility is not as big an issue as you might think.

Unless you are working with both nodes concurrently? Then perhaps there would be a benefit to having the same system, same macaroons, same runes?

You keep a string for both of them. You keep your macaroon for both. Unless you are actually manipulating them there is no difference. It is a blob of stuff. The fact that they are internally different structures, you don’t really care unless you are trying to do something clever.

Including logging, are you able to get assurances that the command that you are requesting being run is actually the command it has run?

Yes. The Commando plugin validates the command. You can even enforce parameters. You can say “They can only do this particular command.” The language is pretty simple. You can say “It must start with this, it must end with this, it must contain this, it must be numerically greater than, numerically less than, lexicographically less than, lexicographically greater than, not equal to, equal to…” You can do any of those comparisons against the command parameters, the command, the time if you do timeouts, “the time must be less than this”. There is also some primitive rate limiting that is coming in so you can say “You can only do this once every second” or whatever and rate limit them. In theory we could add more but in practice it is filtering against the command that they are trying to run and the node ID that they are coming from. With Commando we have already authenticated at a cryptographic level what the peer is, you can test against that as well. You can say “This one peer is allowed to do this.” It is a pretty simple language but it does let you build up some complex things. Of course like anything when you build complex things you might knock a hole in it and accidentally let them do everything instead. Keep it simple.

# c-lightning on FreeBSD

I started to run a FreeBSD server and planning to put c-lightning on it as well. I already have testnet and mainnet Core and two lnd nodes on it. Is anyone running a c-lightning node on FreeBSD? Should I expect anything? I know there is an installation documentation.

We have got some previous reports from FreeBSD when it hasn’t worked and OpenBSD as well. I know users are out there but none of the core people run in. I would love to have a cloud runner…

I think Wladimir has reported on FreeBSD, c-lightning.

It would be nice to have it in CI, if we had it in CI we would spot these things. It is unfortunately off the edge of the really well known map. Christian found a good place that we might be able to CI run MacOS for example which is the other hole we have in the core team. None of us run on MacOS, we don’t test it day to day.

I will stick to Linux for now then. When I get more confidence I will get to a different operating system to test.

We like our FreeBSD friends, we won’t hold it against you.

# Send invoice functionality for offers

I was curious about the send invoice functionality for offers. I could not understand, would you be able to explain it a bit?

There are two kinds of offers basically. There is a normal offer where you are offering me some goods or something and you want me to send you money. In that case I ask you for an invoice, I send you an invoice request, fetch invoice, and you give me an invoice. There is also an offer out, what’s called a send invoice offer which is where you are offering me money. In that case I use the “send invoice” command to literally send you an invoice that you will pay.

So send invoice is…., if you create an offer with offer out then you send an invoice to get paid.

It is the ATM or refund flow where they are offering to send you money. You just send them an invoice and they will pay it. It is a parallel case and BOLT 12 documents these two cases. There’s one, the normal you are going to send me money and I’m going to send you the goods, and the other case where it is the reverse, you will send me an invoice and I will send you the money. They are both called an offer which is a little confusing but one is a send invoice offer and one is a normal offer. It is a different flow.

Cool, and I may see some of you on the [Telegram](https://twitter.com/rusty_twit/status/1423824012010868740?s=20) BOLT 12 thing.

