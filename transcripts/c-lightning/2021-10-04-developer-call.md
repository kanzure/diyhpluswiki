Name: c-lightning developer call

Topic: Various topics

Location: Jitsi online

Date: October 4th 2021

Video: No video posted online

The conversation has been anonymized by default to protect the identities of the participants. Those who have expressed a preference for their comments to be attributed are attributed. If you were a participant and would like your comments to be attributed please get in touch.

# Dust HTLC exposure (Lisa Neigut)

Antoine Riard email to the Lightning dev mailing list: <https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003257.html>

The email Antoine sent to the mailing list this morning. With c-lightning there is a dust limit. When you get a HTLC it has got an amount that it represents, let’s say 1000 sats. If the dust limit is at like 543 which is where c-lightning defaults to, if the amount in the HTLC is above the dust limit then we consider it trimmed which means it doesn’t appear in the commitment transaction and the entire output amount gets added to the fees that you’d pay to a miner if that commitment transaction were to go onchain. There are two problems. In other implementations the dust limit is set by the peer and it is tracked against what the reserve is. They can set that limit really high. You get HTLCs coming in, they could be underneath the dust limit even if your fee rate for the commitment transaction isn’t very high. Basically the idea is if you have a high dust limit, let’s say 5000 sats, every HTLC that you get which is 1000 sats will be automatically be trimmed to dust. If you’ve got a channel with a pretty high dust limit and someone puts a lot of HTLCs on it then all of a sudden your amount of miner fees on that commitment transaction are quite high. If they unilaterally close the channel, the dust limit is used on the signatures that you send to your peer, then all of that amount that was dust now goes to the miner. If the miner was going to pay them back money it is a way that they could extract value. This has been a longstanding problem with Lightning. I gave a [talk](https://www.youtube.com/watch?v=e9o6xepAD9E) on dust stuff at Bitcoin 2019. It is not really new, I think the new part of the attack is that the peer can set the dust limit. c-lightning has a check where the max dust that your peer can set is the channel reserve, like 1 percent of the channel. So c-lightning isn’t as badly affected as some of the other implementations. That’s one side of it. The other side, the recommended fix is that now when you are taking a HTLC and you are saying “This is now dust”, we have a bucket and we add every HTLC amount as dust to this bucket. When the bucket gets full we stop accepting HTLCs that are considered dusty. 

The dust limit is kind of like the minimum bar, the amount of the HTLC that is left has to be above in order to be considered not trimmed and show up in the commitment transaction. You get an interesting interaction with the update fee rate here though. When you are considering whether or not to add a commitment transaction you figure out what the fee rate would be to get that HTLC into a block. The transaction has a fee rate associated with it. Every HTLC has a fee that is has to pay to get to chain. That’s a function of whatever the current fee rate is for the commitment transaction. Every time an update fee rate is sent we recalculate what those fees are. Let’s say that our dust is 500 sats and that the HTLC we are looking at is 1000 sats. If the fee rate is pretty low, the total fee rate for that HTLC is 250 sats, we still have 250 sats worth of value that you can get if this goes to chain. That HTLC won’t be trimmed. But if your fee rate goes up, it is now really high, suddenly the fee rate for that HTLC is 600 sats, now there is only 400 left and that is beneath our dust limit, then that HTLC will get trimmed. Dust limits are set at channel open, that number stays at the same place. But as channels are operating if the fee rate goes up high enough that you had HTLCs that were in the commitment transactions and weren’t considered dust all of a sudden you’ll have all this new dust falling out. Your dust bucket might get full. The [patch](https://github.com/ElementsProject/lightning/pull/4837) that I put up deals with this. You have a bucket and if it gets too high at some point you stop accepting HTLCs that would be dusty within a 25 percent fee rate increase. If the fee rate went up by 25 percent, if that HTLC would be dusty you stop accepting them. You start rejecting HTLCs and don’t add them to the commitment transaction. You keep your total exposure at a minimum, at a bucket number. In the PR I put up the bucket number is 50,000 sats. You can get up to 50,000 sats in this bucket before it will start rejecting HTLCs. But it will be configurable. 

This doesn’t actually solve the HTLC problem, you are limiting your downside risk. In theory it is capped at 50,000 sats or whatever that number is for that channel. I don’t know if you’d call it a real solution, there are several reasons I would say that. The long term plan for how to deal with this, how do you make a little less hacky, is [anchor outputs](https://bitcoinops.org/en/topics/anchor-outputs/). Earlier I was talking about when you have a HTLC and you have to figure out what the fee is going to be for that HTLC transaction, you subtract that from the amount. You figure out whether it falls under the dust limit. With the new zero fee thing, a version of HTLC outputs, what happens is you no longer calculate the fee for the HTLC before deciding whether or not it is dusty. The only number that you need to take into account is the dust limit. When you are deciding whether or not a HTLC is dust you only look at the dust limit. There is none of this fee rate stuff that will cause you to fall beneath that at any point. Then you do the fees for the HTLC on the other side of it, a child pays for parent (CPFP). It gives you more flexibility when you are creating HTLC transactions, you can add the fees after the fact. You save some money on the fee stuff and it is dynamic so you can figure out what the fee rate is after it has gone to chain. You don’t have to figure out ahead of time, you don’t need to reserve it, which means that you don’t have to worry about HTLCs falling into dust as the channel is operating. That is an overview of the bug and the issue. 

I think the mailing list post said something like you can lose the majority of the channel balance to miner fees. I get that when fees go up there are going to be problems with small channels and dust. What I don’t understand is where the vulnerability comes in such that you can lose the majority of the channel balance.

I think the real problem with it was with the implementations where the dust limit can be set arbitrarily high. I think it is arbitrarily high because they set the reserve and they also set the dust limit. As long as their dust limit is under the reserve… If you open a channel for 1 million sats and they set the dust limit to 50,000 sats then every HTLC that goes through there would be automatically considered dust.

It is just affecting small channels? If you had a massive channel of 10 Bitcoin…

No it is for big channels too.

If you have a 10 Bitcoin channel you can lose the majority of your balance?

It has to do with the initial dust limit. The dust limit is configurable, on c-lightning we have a much lower limit than the other implementations do. On other implementations you could set the dust limit to 10,000 sats and then put 10 HTLCs at 10,000 sats that were considered trimmed and then go to chain and that’s 100,000 sats right there that you’ve lost. If your dust limit is high enough… I think the other implementations have fixed their dust limit acceptance of what they’ll consider a valid dust limit. That makes it a lot harder. The attack that Antoine managed to execute against lnd involved setting a very high dust limit, that’s my understanding.

That’s relying on user error? Don’t the two parties agree that dust limit when they open the channel? You have to agree to a really high dust limit?

But there is nothing in the spec that said not to so there weren’t any checks. In the currently implemented implementations it is possible to execute this attack. This is not c-lightning, I haven’t looked at it in a while so I am slightly worried I’ve got some minor detail about this wrong, my understanding is that c-lightning is not as gravely affected as the other implementations. I think we check against our reserve or something. 

It was still given a CVE, a specific c-lightning CVE (CVE-2021-41593).

That’s correct.

I don’t know why it is a CVE if it is relying on the user doing something stupid but I don’t know how CVEs are defined.

It is not a user thing if you can’t configure it as a user, if it is an implementation thing that isn’t user configurable. I don’t think there is a way for you as a c-lightning user to update it. I am not sure how that would be a user mistake.

If it is a massive channel then surely the dust limit has to be ridiculously high. If you’ve got a 20 Bitcoin channel how high does that dust limit have to be for you to lose the majority of your 20 Bitcoin?

I don’t think most channels are 20 Bitcoin.

5 Bitcoin, whatever, a large amount.

I don’t know the specifics of the attack that Antoine was able to execute but I’m guessing it is probably in the few million sats range and not in the 1 Bitcoin range.

Isn’t it the case that this dust limit and the reserve is configurable by the peers? It needs to be an agreement between the two nodes. If a peer is malicious executing this attack they can raise both the reserve and the dust limit arbitrarily. If it goes high the channel opener can lose money to miner fees.

The reserve isn’t configurable in c-lightning. It is always 1 percent. 

The other question, the fee amount cannot be bigger than the reserve? That is checked. But there could be multiple of these HTLCs under the channel reserve limit each but added up they would all be contributing to miner fees and the channel balance is lost. How many concurrent HTLCs can we do on c-lightning? It is 283 or something on lnd I think.

The max number of HTLCs on c-lightning I believe is 483. I can’t remember if it is configurable.

# Individual updates

I was working on the [DNS stuff](https://github.com/ElementsProject/lightning/pull/4829). There were some questions I asked Christian. I just need to finish it. It is working, you can announce your DNS hostnames and you can receive them. Currently in my branch resolving them isn’t quite ready yet. That is a showstopper. In the last RFC meeting I think it has been decided that we go with both proposals. There was one proposal with DNS, the other one we return the inbound IP. When you get a connection from another peer you send back their IP address to them if they come with an IP address. They can resolve stuff on their end. That is much easier to do so I think we go with both. Both have pros and cons.

What are the two proposals?

Currently you can just announce IP addresses and Tor addresses. My proposal was to add DNS addresses so you can announce a dynamic DNS hostname that is managed by your router box or whatever service you are using. That way you can easily operate a direct connected node in your home without relying on Tor which is good in my opinion. It was missing and there has been discussion on how we are introducing some centralized service. I agree it is a centralized service in a way, every user can decide to use their own IP DNS lookup service. But your node has to ask a DNS server what the correct IP address is of node XYZ. I think t-bast wasn’t very happy with it so we talked about what the problem is here, why not update your IP address? I said it is not so easy to know your correct IP address when you are at home. The reason I brought this up is because I want to fix the situation for users that have local home internet connections and not some internet hosting provider backend stuff. A lot of users have problems with NAT and such, it is not easy to announce your correct IP address even if our service would update them. We could in theory try to check if we have new addresses but that would only work reliably for IPv6. That is why we go with both proposals. The assumption then is when your node sees from a handful of other nodes, a certain threshold or percentage of other peers, they say “Your IP address is another one” then your node know with a certain reliability that it can start to announce a new address. Other nodes are able to connect to you. If there is a wrong address in it it is not too bad as long as you don’t spam the network.

By DNS you just mean a domain name? A registered domain name and then broadcast that in the address?

Exactly. You can use any domain name. I think the rationale is to use dynamic DNS domain names because fixed ones, there isn’t a real use case. You can already announce your IP address and be done with it. For the dynamic ones a lot of home internet equipment already has support for dynamic DNS. If you look into your router there is sometimes some checkbox that you can activate. Then you get a session number dot linksys.com or whatever. You can use that to announce your host, that would be great. Then maybe we could think about including the UPnP stuff to also open up the inbound port. That would be an option to make it even easier for the users. I already committed the code so if anyone wants to look at it, feel free. PR 4829, the other one where we send back the IP address it is not opened yet. If anyone wants to pick it up I think it is a rather simple PR but the devil is in the detail. I thought mine was simple too, it is not.

My current interest lies in figuring it out what are the minimum contents of the lightningd sqlite database. My node’s database is getting bigger after months of running. I am figuring out what is the content that does not need to be there, which is not going to be used anymore, which is there only for historical reasons. I am just formulating my questions. A related issue is [4824](https://github.com/ElementsProject/lightning/issues/4824). It was mentioned by Rusty in one of the [recent meetings](https://btctranscripts.com/c-lightning/2021-09-06-developer-call/#persisting-or-purging-data-on-dead-channels) that we could figure out what is the minimum content and what is the extra cache which helps the Lightning daemon to run faster but without that data it can still receive data from the Bitcoin daemon and other things.

I was trying to open up a Bitcoin Core sqlite database just using sqlite and I couldn’t do it so if you could help  me with sqlite that would be very handy. I was just using basic sqlite commands and they weren’t working and I don’t understand why.

Did you see the [hacking documentation file](https://github.com/ElementsProject/lightning/blob/master/doc/HACKING.md)? It mentions some sqlite stuff.

vincenzopalazzo: This week was a calm week, not much code. I worked on [PR 4782](https://github.com/ElementsProject/lightning/pull/4782), there is some documentation missing on the `make check` command. In the last meeting we talked about how to achieve the solution, I implemented it and it is on GitHub. I also fixed a bug in Lisa’s library.

I look forward to looking at that, thank you.

# c-lightning GraphQL prototype

Robert Dickinson demo: <https://www.youtube.com/watch?v=pVkyRxs-QTI>

On my side I’ve been working on the GraphQL implementation for the RPC call. It is exciting but on the other hand it is on the fringes, what does this have to do with c-lightning or Lightning in general.

I am really excited about it. GraphQL has been something we’ve been talking about adding for years. Having someone working on it is really great. 

It is very powerful. I can see this really changing the face of how we interact with the RPC layer.

Are you adding it as a layer on top of existing RPCs or are you adding a new RPC that takes GraphQL syntax?

It is a new RPC. I started with `listpeers` because I wanted to break out the channels part. Instead of doing `listpeers` now you can just do GraphQL and give it straight GraphQL.

So good, I’m excited.

The cool thing is you could do 5 RPC calls in one, in theory, I have not implemented it for all RPC calls of course. That is where it could lead. It is very powerful in that sense.

In my earlier career I worked as a mobile dev. I never worked on an API that offered GraphQL stuff but it is super powerful for anyone who is adding client interfaces on top of backend. It is really great.

Did you discuss with Christian, you said on Telegram that you’d prefer to have some GraphQL stuff in the core of c-lightning rather than just a plugin? I think you said it was potentially more powerful. Did anything come of that discussion? Is it going to be a plugin?

This is not even in a PR yet. I don’t know what direction it is going to take. As far as what I’ve done in my demo, that is implemented directly in lightningd. That allows something that you can’t do with a plugin, you can optimize the processing to create the data. Using the `listpeers` example, when you do `listpeers` it gathers all the channel data and presents that in the JSON output. With GraphQL implemented in lightningd you are able to avoid going into the channels array unless it was actually requested. As an example it allows that level of optimization. Whereas if it was done in a plugin then you would be doing the whole RPC call and then filtering out. This is not as beneficial. There is still a lot that could be done with plugins as well and I can imagine that we will have a plugin for additional features also, for example for accessing the database.

vincenzopalazzo: With a plugin you can run different commands in parallel like `listpeers` and `listnodes`. If you were to display the data on some website you need to join these commands. In `listpeers` you have some information and in `listnodes` there is other information. With a plugin you can make some queries and run parallel commands and after join the result. I think a plugin could be very powerful also. I don’t know how you implemented the command line with GraphQL but another idea for a plugin could be this one.

If anyone is curious to look at the code, it is in a [branch](https://github.com/rl-d/lightning/tree/listpeers2) called `listpeers2`. You are welcome to check that out if you like. For the week going forward I will be working on doing tests for it and hopefully after that opening a PR.

Awesome, looking forward to it, that sounds great. It sounds like it probably won’t hit this release but the next one will be really exciting.

Probably too aggressive to get it into this release. I am still new to the project, new to GitHub and everything. It will take some time to get it perfect.

Telegram discussion on the GraphQL prototype

“This is neither a mere filter, nor a direct-to-database approach although the idea started with both of those two ways. But what I showed in the demo was a re-write of `json_listpeers()` and subfunctions so that instead of building the JSON output in the normal fixed way it builds only the parts that are requested by the supplied GraphQL pattern”

“Absolutely loving it. As you mention it can save us from doing unneeded work when all we care about is a subset of information, and we can still keep a default query to maintain the pattern we currently use. Is your demo implemented in C or is it built on top as a PoC? We’d likely want to integrate it with the way we query internally and build the responses in order to reap the performance benefits. Also this would be an awesome solution to filtering as well, as it currently stands each filtering option takes a separate CLI argument.”

“Agreed it is pure C, I will push it to GitHub so the code can be inspected.”

“So cool! The only question that I have is about the GraphQL property for each RPC command. Maybe it would be better to have a plugin like `graphql.c` that exposes a method to query the node with GraphQL? With GraphQL we can join the result of different RPC commands in a single query I think.”

“I tried the plugin approach and it has advantages and disadvantages. 

Advantages: It is a plugin not touching the core code. Any other plugin could use its GraphQL RPC. It could provide DB access. It could provide convenient access to existing RPCs.

Disadvantages: No optimization of existing lightningd RPCs. No performance benefit when used to request data from existing RPCs.

I’d love to do the plugin approach to get its advantages for DB access but for RPC data I think it’s not the best approach. As you mention I would also like to consider alternatives to adding a property to each RPC command, maybe one new lightningd RPC for accessing everything the GraphQL way?”

# Individual updates (cont.)

The only thing I was playing with regarding c-lightning is the Spark 0.03 release candidate 1 which has a graphical interface for offers, BOLT 12. It is working so I can report that. I’ve seen a lot of requests on my posted offer, none of them paid, only the ones I paid. It doesn’t matter, I just realized that the privacy part is not implemented yet with blinded paths. They are not available yet. You can use these reusable QR codes which is great. We’ll put it into the Raspiblitz so people can play around with it and maybe it will get more traction. The good thing is you can redeem them in this web interface. Some are afraid of the command line, we’ll see how they manage with c-lightning.

Cool, I am excited about getting offers fully out into the world. That’s a big opportunity for Lightning. I don’t have anything else other than I expect a release candidate to be out next week. Christian is running the release this time so he is a good person to check in with if you have a PR that you need to get pushed out in the release, 10.2. I think it is mostly going to be small patch things. 

