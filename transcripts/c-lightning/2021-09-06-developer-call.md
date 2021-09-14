Name: c-lightning developer call

Topic: Various topics

Location: Jitsi online

Date: September 6th 2021

Video: No video posted online

The conversation has been anonymized by default to protect the identities of the participants. Those who have expressed a preference for their comments to be attributed are attributed. If you were a participant and would like your comments to be attributed please get in touch.

# Individual updates

I’ve been mostly shepherding the pull requests on c-lightning and looking into issues we need to fix for the coming release. Expect a couple of updates coming from me regarding people being about pending pull requests that are marked as draft. I want to get as many of those in as possible and get them lined up. We have about a month before the nominal release date. We are on good track to get that stuff on. We have merged a couple of pull requests, some fixes, some enhancements. Everything is looking good. I have been addressing a couple of outstanding issues that have been filed and I will be picking up the work on the pay attempt grouping that we had. Try to hunt down a couple of issues when performing payments. There is one that I don’t know how to address or whether to address at all. That’s an issue where a user was trying to perform a payment that was larger than the sum of all of its outputs. He was surprised that we didn’t fail immediately. This is sort of a special case where we can’t do much because that error might happen further out. We might not actually see that outright. For us having complete information about our peers and the sum of spendable capacity, we might special case that and actually provide the experience that they were expecting, namely that it fails immediately and doesn’t even try it. What happens now is basically we try to send it in one HTLC, then we split it and surprise, one of them passes and then we try and try again with the remainder without having a real chance of ever finishing. I might special case that just to be more in line with what people expect from behavior. And hopefully getting back into the game of reviewing stuff and getting things merged as quickly as possible. Looking forward to the release.

Vincenzo, I want to thank you for the [lnprototest stuff](https://github.com/ElementsProject/lightning/pull/4738). Vincenzo and I have been wrestling with this. I added a single Python dependency and it descended into pip hell where it was trying to resolve all the dependencies, the CI was timing out after 6 hours of failing to resolve them. It turns out Python dependencies are a bit of a black art. We have been trying to do some upgrades of various things to try to cut that Gordian knot. I hope we are closer this morning than we were last night.

Can you speak about the approach? I read the PR, it is just bringing the packages internally but then you have to maintain them? There are upsides and downsides to bringing the packages internally?

The problem is the packages are internal. We have these `pyln.spec` packages that are inside c-lightning. That is really a historical artifact. They should nominally be their own Git repository and everything else but we create them and we tend to maintain them. We have `pyln.spec` and `pyln.proto` and a whole heap of fundamental Python building blocks that are inside the [contrib](https://github.com/ElementsProject/lightning/tree/master/contrib) directory of the c-lightning repo. They only tend to get released when there is a c-lightning release and then we push them to the pip repo if we remember. We also have a separate project [lnprototest](https://github.com/rustyrussell/lnprototest) that uses those. We also pull in lnprototest to test c-lightning again lnprototest. Now we have this three way Python love triangle with the various dependencies. If those dependencies conflict, I’m not even sure they do conflict, or are too underspecified it seems to get into this nasty loop. I wanted to clean up dependencies and update the spec. If I updated the spec it broke lnprototest which meant that our CI didn’t pass. I couldn’t actually get an update of the spec into master, I had to update it and then use the PR, push straight to PyPy and then change lnprototest to rely on the ones that pip could install. In the long term we’d like to move them out into their own repository and then pull them in. They would be completely independent projects but for the moment they are inside c-lightning and it makes it a bit of a knot with our test dependencies. Hopefully a temporary thing. We have some weird things like Mypy versions that wouldn’t parse our Python for various known limitations of Mypy. One of them was asking for a specific version. The other package had been updated and was asking for a much more recent version. They were simply conflicting. Just standard teething problems. I think we’ve worked our way around that now and hopefully it won’t happen again. It was unusual to add this one line dependency to `requirements.txt` and watch the whole thing fall into a hole trying to install. I did not know this was a thing but this week I learnt.

I have a prototype for a plugin that collects data. I also display some of this data on my dashboard of the node. But I have a couple of bugs that I need to fix. I will propose this as a Master’s thesis. Hopefully people from the c-lightning team will help me when a professor says “This is not true”. People that don’t know much about this stuff. We will see what happens around that. I am working on a pull request that I opened on c-lightning, dealing with a SQL statement that Christian helped me with, a generic query.

If you ever need any data, let me know. I have plenty of stuff lying around that I never get around to analyze.

I have been working on [BOLT 9](https://github.com/lightningnetwork/lightning-rfc/blob/master/09-features.md). I connected the node through a web socket and run the list commands through [Commando](https://github.com/lightningd/plugins/tree/master/commando). This is the last week of my Summer of Bitcoin program so the last 2 or 3 days I have been learning how to use the wallet that I have got. I haven’t worked with it before so I was researching how I should get Bitcoin and how I convert it into the fiat currency, all of those things. I’ll probably update the documentation tomorrow and then I’ll put out an article. I am expecting in a week or two that I will implement [BOLT 4](https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md) so that I can release that through web socket and fetch invoices natively without the API.

Aditya has been working on a Javascript implementation for offers. He can connect and speak Noise NK, so [BOLT 8](https://github.com/lightningnetwork/lightning-rfc/blob/master/08-transport.md), he can speak to a native Lightning node over a web socket. He has managed to drive Commando at my end which is kind of nice. He can take a rune, he can use the `getinfo` rune that I handled out on [Twitter](https://twitter.com/rusty_twit/status/1431868936077799434?s=20). He’s implemented that. The next logical step is to be able to craft an onion message so that he can actually do a `fetchinvoice` all natively in Javascript. At the moment he has an API that goes through bootstrap.bolt12.org to fetch the invoice. But now he can actually speak native Lightning the next step is to create the onion message and then parse the reply that you would need to arbitrarily route any messages, in particular `fetchinvoice`. That would be a complete solution. The use of web sockets is a known limitation. Obviously Javascript generally from a browser anyway can’t reach out to an arbitrary port and start speaking arbitrary protocols. There is a web socket extension that is proposed in our spec process but also there are a number of external proxies that you could use. You can connect to them and then they will connect to the native socket, proxy back and forth. You could use the same thing to connect to any Lightning node. That’s great progress. The actual construction of the onion and the onion message, which is actually in flux because we tweaked the [spec](https://github.com/lightningnetwork/lightning-rfc/pull/759) recently after feedback from Matt Corallo. It is a little bit more complicated than the stuff you’ve done so far. It is probably one of the trickier parts, the onion construction. But it is very well documented. 

Will you be continuing your work after Summer of Bitcoin or do you have to go back to university?

I have regular classes right now, the university is running online because of the virus. I’ll try to commit my time.

It doesn’t seem to be slowing you down very much. I hope you are paying attention in classes at least.

I am looking forward to getting this released. As an aside having all tooling to drive your node from a web browser is kind of cute. It is a nice party trick to be able to do that. It does mean that your node needs to install an experimental PR to do web sockets and then the Commando plugin. But hopefully by the next release that will be a lot easier. 

We started with a couple of iterations on the [gossmap py-ln support](https://github.com/lightningnetwork/lightning-rfc/pull/759) which is somehow usable right now. Vincent had some additions regarding dependencies. We changed the requirements a bit but no surprises there. I think I fixed with Christian the autopilot bug, there was an initialization issue that has been resolved. There was a small [pull request](https://github.com/ElementsProject/lightning/pull/4760) in the main repo which added to the hook the commitment revocation the channel ID and the commitment number. I am not sure who will need it but it was missing for some reason. A watchtower doesn’t need it but maybe something else will need it. 

# The getstats plugin

I am currently digging out my old plugin branch which is the `getstats` plugin. I talked with darosior. I can show you. It is something like the Sauron (correction: Prometheus) plugin but with a command line interface. I want to offer an API that gives you data about past events in your daemon. Everything you can get, maybe configurable where you can enable or disable certain time series. If I don’t set anything it captures everything I get from any hook, any notification. It also captures how many and what commands are called over the interface. Then you can access this information, this time series. You can get the name of the time series, `tsfrom` and `tsto`, those are timestamps. You get the data within this time range. You also have `getstats_average` on this time, max, median, minimum or even the sum of everything that happens. In the future it should also do stuff like ASCII plotting. The idea is to have an API that other plugins can use internally to make better decisions. When you think about the fee adjuster for example, it needs more information in order to make smart decisions about how to set the fees. I think we could derive some information from the `getstats` plugin. For example, failed forwards, it counts those. Or the payment size, whatever. Those are the `get` functions. There is one `liststats` function here which tells you what time series you have. We have coin movement, let’s execute that for fun. 

`lnct getstats coin_movement_debit`

Since this is a rather new database, I reset this at 15:00, there is not much here yet but you have some data. 

`lnct getstats_min coin_movement_debit`

You get the minimum amount or the median amount or whatever. It doesn’t make sense on every dataset but as you can see there is not only the counting data but also events which could be plotted.

`lnct summary`

This node has 3 channels. Let’s pick out the time series for the middle one here. This is what you get from the `listpeers`. It captured this every 15 minutes. This is a gauge. I also have events which are triggered by hooks and notifications. 

This overlaps a lot with what Vincenzo is doing with his Matrix stats. 

We should talk.

I think the idea is clear on what I want to do here. I have a programmable interface that can be used in other plugins to get data. It also tracks stuff like failure codes or even the amount on those failure codes.

`lnct gestats sendpay_failure_code_204_msat`

 `204` is a common failure code, what is the amount that has been failed with this code? That is what I’m working on right now.

Did you say it is similar to Prometheus and Vincenzo is also working on a plugin called Matrix, have I understood that right? There are 3.

[Prometheus](https://github.com/lightningd/plugins/tree/master/prometheus) is something different. You have a web server then. The Prometheus plugin just offers an interface that you can use to import to a Prometheus server. It is a big machine that you need to have, then you can have charting and query functions in a web interface. This doesn’t have an external requirement. It offers no web interface but an API that can be used internally. That is the main difference I guess.

You mean Prometheus rather than Sauron. [Sauron](https://github.com/lightningd/plugins/tree/master/sauron) is the watchtower.

Right. A CLI replacement for Prometheus. 

That’s cool. This is a good point for me to mention that on Wednesday UTC I would like people to run some stuff to watch one of my channels. I am trying to measure propagation through the network. It is on [Twitter](https://twitter.com/rusty_twit/status/1434751205608079365?s=20). We have this question. If you increase your channel fees you should accept the old lower fee rate for some duration while it still propagates if you want to be friendly. It is an interesting idea, it is probably correct especially if it is configurable. The question is what should the default value be? How long do we expect it to take? We simply don’t know the answer. We can guess because you are supposed to batch data for gossip and send it every 60 seconds. But I would like to measure it. Unfortunately the granularity isn’t going to be enough so you will have to run some command line that sits there and every second checks and prints out the time and the new values. I have asked people to run that for 24 hours from Wednesday UTC. You can run it for longer but I will play with my channel during that time several times and gather all the stats, see when did people see the updates? It will be interesting if someone doesn’t see one of the updates. If our propagation is loss-y. There is a little science in there along the line of measurement. Thank you for reminding me of that. 

My other question was the 15 minute duration, was that something you decided was enough data?

It is the current minimum sample size. What this should do in future, you could have hourly candles. It is not a financial chart but it could add up all the numbers within 4 15 minute buckets. I don’t want to stress the disk too much so 15 minutes is fine. It should be configurable in the end. The query API should also allow different ones so on the fly the data gets merged together. That is on the roadmap.

Where are you storing the data?

It is a distinct SQLite DB. Similar to the [Summary plugin](https://github.com/lightningd/plugins/tree/master/summary) that captured the online, offline data for other peers.

That is probably better than [datastore](https://github.com/ElementsProject/lightning/pull/4674). 

I don’t want to bring up additional dependencies. I think SQLite is fine. Especially since that is information that can get lost, that’s ok.

It would work but yeah it is probably overkill. And you probably want to do more powerful queries than just listing them in future anyway. 

Exactly. Thinking about a query API that combines several datasets mathematically so you can plot information like how much fee have you set and how many errors did you get? Was it more probable for routing to have a higher or lower fee? Stuff like this that should be accessible with this kind of stuff.

I can Z-man getting very excited about using that for [CLBOSS](https://github.com/ZmnSCPxj/clboss) as well.

Maybe. This plugin is a dependency for CLBOSS.

I think this is the way we are headed. We are headed to more dependency plugin things. Hence my emphasis on trying to get the [Reckless plugin manager](https://github.com/darosior/reckless) in for the next release. We’ll see how darosior goes with that.

# Raspiblitz update

We’ve started to put together a package for the Raspiblitz where you can choose to run c-lightning or lnd. There is a release candidate 1 which surely and quickly will be followed by a release candidate 2 and probably a couple more. I’ve been busy with making it easy to do the steps for increasing the security and the resilience of the c-lightning node. Encrypting the hsm secret and then being able to use an auto-unlock feature when the password is stored on disk. Otherwise keep it in memory until restart. There are a couple of features where you can backup automatically when you reset the wallet or change the SD card. There is a copy on the SD card as well. On the disk you can restore the whole wallet. There should be only edge cases or very intentional cases where things get lost, multiple backups even when it is not asked for. We are using the [backup plugin](https://github.com/lightningd/plugins/tree/master/backup) as well so the channel database is continuously backed up to at least the SD card. Later we will probably introduce some off-site backup option. We won’t be able to provide a server but if someone has something running at home it should be utilized. We use a BIP 39 seed with the reference implementation in Python to give the user this seed rather than making them write down the `hsm_secret`. The seed is also being stored near the `hsm_secret`until it is encrypted. By default it is sitting there and then you can make it secure. There is a lot of testing involved with that.

# HSM secret, HD keys and descriptors

I wonder, the BIP 39 secret thing, certainly we should support that in `hsmtool`, probably bring that in closer so that we’ve got a standard, “This is how you represent your secret”. Lifting a string of hex or something is a little bit nasty.

It is fairly straightforward. It would be a very simple script. The recommendation is in the docs already, how you can generate the `hsm_secret` from the seed. I had a conversation with Lisa on Telegram about this, waxwing was asking about the derivation path to start with but then found out with the `hsmtool` you can dump the onchain descriptors. It is a completely arbitrary derivation path. You wouldn’t be able to make an xpub or some kind of master public key which you can put into a wallet and monitor the onchain activity of the c-lightning wallet? Would that be possible?

You need the descriptor because the path is unique, the path is not standard. You have to have the descriptor to get it imported. It can’t be a ypub or zpub or something like that.

I used the descriptor to generate hundreds of addresses and those addresses are imported into Electrum. I can see all my activity on c-lightning and I can see it in Electrum.

Other than the transition pain there is nothing stopping us from using a more standard derivation if we wanted to. We’d have to handle both and have it in the database marked that this is a new derivation versus the old one. If it is something people wanted, it is just software we could change it. It is kind of nice to be able to import a xpub and watch everything that c-lightning is doing.

My approach to it is we should support descriptors and descriptors are fine. At some point all wallets will support descriptors and then you’ll be able to import your c-lightning stuff, they just haven’t caught up yet.

Is that true for future c-lightning? Is that true for things you haven’t done yet in c-lightning or do you have to keep importing new descriptors as we go?

What do you mean by future stuff? It doesn’t matter what the derivation path is, even if we change it… If you export the descriptor it has got the \* (star) which is the incrementer. It makes it such that you can import the path that we’re putting all UTXOs on and it will autogenerate it. There is enough syntax there to express all of the UTXOs that we spend to this path.

That’s what I couldn’t remember, if we were actually doing proper derivation paths in our UTXO derive. From the `hsm_secret`we use HKDF, we use a completely different system to generate our keys. But I think we get to some point where we generate our new addresses actually using BIP 32.

The `hsmtool` outputs the pubkey, I can’t remember if it is the xpub, the key at the point at which we start using the derivation. I can’t remember if it is BIP 32 to derive the first key. There’s this weird step between the seed and the derivation path but you can get around with that with the descriptor.

We also don’t separately derive our change addresses from our receiving addresses because there has never really been a point in doing that. But we could. Even at the API level there is nowhere to say “Give me a change address”. But it is another enhancement we could do and it would make it cleaner if you were to import it in a different wallet. 

Would it be possible that you have a different wallet and that would generate addresses without involving the c-lightning daemon?

In theory we could make it such that c-lightning takes a descriptor and then from that descriptor it generates new addresses. You could import a descriptor into c-lightning and that would be what we used instead of our internally derived one.

Importing addresses always has this backup problem. You no longer have a single source of truth from which you derive everything. You now have this extra thing you have to backup. It is always a problem in some sense. That’s why we don’t support importing addresses at the moment. Because of the added problem of backup. We certainly could.

And rescanning.

Yes. If you solve your restore problem you can solve your rescanning problem I think? But yeah.

That is the problem with using external wallet software. Mainly with deposits, if you spend it that is picked up by the c-lightning daemon but if you deposit it wouldn’t be. There could be some confusion there if your balance didn’t change after sending to the same wallet.

I’m tempted to do all or nothing. You either disable the c-lightning internal wallet altogether and use everything external, which is certainly a valid model…

Does it work with force closes?

No you always have a magic script at that point. Force closes will always be weird looking things that someone will have to understand. Force closes will always go to the internal wallet. You need something like Miniscript to express the requirements I think for force closes. Even then I’d have to think about it because the way we twist the keys could become problematic there too. I think force closes will always have to go to an internal wallet. You’d need a wallet that implemented enough Lightning so that is almost a Lightning node by the point it can understand those addresses. I think that is true, it is always going to go to an internal wallet. You can’t completely disable the internal wallet. Something has to recognize how to spend those things. In theory it could spit out descriptors for those to an external wallet and have it deal with it but in practice external wallets don’t deal with CSV delays and the other things that are involved there. I think that is going to have to be internal.

So your all or nothing quandary is basically all. Nothing isn’t an option.

It is an ideal case though. If everyone supported arbitrary descriptors and we had our nirvana, I could teach any wallet to spend anything then maybe you could do nothing. You could feed it all the information it needed and it would understand it and spend it. We are not there so I think you are right at the moment. Not quite all, you could have a transitory thing where we collect it in the internal wallet but we immediately send it out to the external wallet. If we really wanted to, it is extra fees and we deliberately avoid that step at the moment. We remember enough information to spend some outputs directly even though they are CSV encumbered just to avoid those extra fees. We are stuck with an internal wallet for the foreseeable future, I would say that.

# Persisting or purging data on dead channels

Is there anything else that you want us to tinker with for next release?

I think it is plugins’ jobs as I dive into using a c-lightning routing node more. Especially when running CLBOSS I would want to see why the channels are closed. Who was the one who triggered the close if it was a cooperative one? That is something which for now I could only query the database. Even that is not that easy. I don’t know enough SQLite to do that. It should not require the database externally anyway, it should be going through the lightningd.

The state change history is in the `listpeers` outputs?

Non-closed, yeah.

It is until it is getting forgotten by the `listpeers` after a couple of hundred blocks. You can’t go back and see what happened last week.

I can capture that in my plugin.

There is a proposal for a list local channels. Somebody pointed out that it should also remember the dead ones. Rather than cluttering up `listpeers`….

A `listpeers` switch option which outputs old stuff.

Including dead ones would be useful for this kind of stuff. If you haven’t looked recently and you’re like “Where did my channel go?” At the moment it is dark, that is a very good point. I did put that [PR](https://github.com/ElementsProject/lightning/issues/4729) as a good first issue, I don’t know if anyone has picked it up.

I think there is someone who is working on it. I started to work on a PR but I opened the PR when you were refactoring `listpeers`. We closed my PR waiting until you were finished. I am waiting to see for a PR to be opened and maybe in the next week I can start refactoring my old PR adapting this new PR. 

I’ve just noted on that issue that you could also incorporate the other issue which is adjacent to it, saying that it would be better to include dead channels. That would be the place to get all the information, preferably as a flag saying to include the dead ones.

The dead channels are still in the database? They could be listed?

I believe so. We stopped deleting stuff from the database because it is hard to undo once you’ve deleted things. The database just doesn’t grow that fast. If you are adding to the database every time you’ve confirmed a channel it is self constraining. If you can afford to open that many channels you can afford a large disk. 

The vast majority of data in the database is currently the UTXO set with all of its indexes. This can be cleared out quite easily. There is no danger if you do. It is just an optimization for channel verification basically. Without that we are around 20-30 megabytes even on a busy node.

My node has 4GB.

Then you have way more forwarding than I do and I’m jealous. I do about 50 a day on my Raspberry Pi.

I do 1 every 2 weeks.

You may not be the one we should be measuring.

I am not always forwarding but when I do…

Should I really be running the Greenlight nodes come to think of it?

I was also asked by Zoltan that we think about purging. He has a very busy node as well, works on the rebalance stuff, maybe we should start on that.

Do you want to look at what the sizes are? Look at where the low hanging fruit is for where we should purge.

Table sizes would be great, just to get an idea of what is consuming the most. There are SQL statements that I can share.

That would be good actually to figure out. By policy we have not been deleting data.

Also using the backup Python [plugin](https://github.com/lightningd/plugins/tree/master/backup), it works even on a busy node, but I need a fast USB drive. USB 3.0 is recommended.

I have a question about the database. We have the datastore plugin and we also have a RPC method for the new release. If I am a plugin that can store data inside the main database of c-lightning it can be dangerous if I put a lot of data inside this database. For instance if I am putting my Matrix plugin in the main database, not a separate database, this database can grow fast. The backup plugin starts to become difficult. Maybe it is possible that c-lightning starts a database for the c-lightning stuff and we have another database for plugin stuff. If we miss the plugin stuff we don’t care but if we miss the database stuff we miss the channel information.

And maybe a place to bury the dead channel information.

We could separate things that are critical and ongoing. There are things that are critical for the ongoing operation of the node and there is everything else. Everything else is forwarding stats and other stuff like that. Even the UTXO cache, things like that are non critical. Channel states and things are critical. There is a small core of stuff that is really critical and we could separate the databases, have two. I blindly say what is critical and what is not. It is still painful to lose the other database. I think about things like the accounting plugin which Lisa keeps promising to polish up…

You don’t lose money.

Well no, when the taxman comes I can’t actually track all my payments, I do lose money. In a technical sense there is important data and there is other data but from a meta sense don’t lose any of my data please because it all may be important. I’m not sure separating the database is necessarily the right answer although there is definitely a level of criticality here. Ideally though we would manage it such that you would never have to worry about it and we would keep all your data safe. I think a last resort would be a split into critical data and non-critical data. I would like it to be for as long as possible a single database that you keep safe. Everything just works. We’ll give in if we have to. I just checked my database, it is also 3GB. 

We can meet halfway and just have a clean DB method that purges a couple of known things out of the database. For that depending on the sizes that we gather from everybody on what is critical we can do that quite easily. The UTXO set is important only for the verification of the channels. For the initial gossip sync it really does create a huge speedup. Once we are caught up it is just sitting there until the gossip store gets corrupted again and we sync again. It hasn’t for a while.

That has become better.

We have autoclean as a plugin. We’ve had it for a long time. It would make sense to extend that perhaps to do other kinds of cleaning. At the moment it does invoices and that is it. Extending autoclean to cover more stuff in the database is probably the right answer. When we are cleaning stats I really would like to keep them somewhere useful, even if we have a summary record in the database itself. “I removed forwards and there was this much total” or something. But let’s see what the actual problem is. I’m not sure what we should be cleaning, we’re guessing forwards, maybe that is a red herring. I actually don’t know how to measure the size of table, Christian if you want to give us some commands to run…

I just noticed mine were for Postgres and SQLite doesn’t provide a good facility…

I can do it with SQLite dump and grep, that is fine. Judging solely by the number of bytes per line. grep and `wc`, I can do it.

# Individual updates (cont.)

I am a friend of Michael who helped me setting up my first full node, a Raspberry Pi, I keep picking his brain. I am a total newbie, this is quite a big achievement today. He mentioned that he is going to attend this call and that it is open and free to join. Hope you don’t mind me being a listener here.

We all had to set up a node for the first time one time. We’ve all been there.

It is hard to follow but it is amazing to hear how things are moving, the Lightning Network keeps evolving and is actually being used. I also have a live node which was set up by Michael and seeing the forwards every day is amazing.

Every day? How do you guys do it?

There must be a secret ingredient, I am not able to tell you.

Currently your node is configured to use the median fee calculation on your peers. That brings up your forwarding numbers a lot, which I did by intention to mess around with the node a bit more to get traffic. From an economic standpoint it is maybe not the best decision but it is a start.

Here I was throwing the big machinery at it. I was taking the Lightning topology, computing a potential edge to every other peer and then computing the between centrality and looking for the best improvement. It got me stuck with lots of Tor nodes. Never tell a computer scientist he has to optimize something.

I know at least one person has said they won’t connect to Tor nodes at all simply because they are too unreliable. But I suspect some of that may be solved by regularly pinging the Tor nodes because their circuits break. Rather than finding out the circuit is dead at the point you need to forward…

I am not too sure about this yet.

It probably won’t make it worse is my only thing.

I am thinking about tweaking routing stuff to bias against Tor, maybe as an option. If you want to make a reliable payment, maybe without Tor.

I like to think we should probably work on the problem before giving up.

Last week I was hopping between a bunch of different stuff. It wasn’t super productive. There is more to be done for the way funder handles output selection. I’ve got it mostly done, I’m just working on tests. I was at a conference last weekend in Dallas and I talked to some people that work on [amboss.space](https://amboss.space/) which is a big node directory. It is a fancier version, more community focused version of [1ml.com](https://1ml.com/). I was talking to them about what it would take to get liquidity ads added to their dashboard. They run lnd nodes and it is hard to get liquidity ad information out of lnd nodes. Every node on the Lightning Network has all the data about liquidity ads because it is sent out through gossip. It is just a question of how do we make it such that you can digest it and display it. In lnd they save it in a field in their database, I was like “I’ll write a tool” except that they don’t really have a SQLite thing, they use RocksDB or something. I thought I’d write a tool, reverse engineer the schema which is a key-value store in buckets database structure thing. I decided instead what is probably more sustainable in the long run is to build a web service that you can subscribe to. It will take liquidity ads and make them publishable over web protocols. That way I can use that to drive a Twitter bot and anyone who wants to subscribe it, it will be a lot more accessible that way. It turns out that the Amboss guys, setting up a c-lightning node and figuring out how to digest that was not high on their to do list. Hopefully this can be something they and anyone else who wants this data can plug into a little more easier. I did mostly investigation work this last week. Hopefully next week will be more build focused. 

Hearing about the lnd database I am so happy we chose SQLite.

They keep all of their gossip data in there too, it is big. People were running into problems on Raspberry Pis, the 32 bit machines were falling over when their database hit 1GB or something like that, I’m paraphrasing here.

I have three lnd channel databases, one is up to 6GB with compacting. It is crazy. 32 bit systems, if you run the default Raspberry Pi OS which is still the recommended thing from the Raspberry Pi foundation, that is 32 bit despite the processor being 64 bit. It cannot deal with a database over 1GB. You get to 1GB and then it cannot map enough memory to be able to do the further things it needs to. Roasbeef has a nice explanation on the GitHub issue but basically they can’t fix it. They are looking into not providing 32 bit binaries anymore although you need to be a reasonably busy node for it. It is mostly payments, I would be surprised if the gossip data would be stored, but all the failed payments and all the previous payments are. They can be cleared but if you are running a rebalancing script then you can grow your database in a month above 1GB.

It is hard to know when you start out how big your node is going to be. If you start out on Raspberry Pi and then you grow really big…

You have to migrate for sure.

But you can migrate from a 32 bit system to a 64 bit system?

Yeah, we tried all kinds of cross infrastructure migrations and it worked out so far.

There were some doubts about that before.

You set up a new node and you send it all your funds.

No, no. I mostly copied between 32 bit and 64 bit ARM. First of all when we started to run 64 bit on the Raspiblitz and the other node implementations use 64 bit base images now. I moved from this setup to a FreeBSD which is AMD 64. That worked out too but it was a bit scary.

The reason we use SQLite is simply that I’m lazy, not that I’m brilliant. Databases are hard and data storage is hard as they found out. The 32 bit limits and stuff like that. If you ever read some of those SQLite docs as far as their development and the horrible things they have to do to make it work, you don’t want to be doing that yourself. 

# Channel types and channel upgrades

I have been distracted by spec stuff. There is a lot going on in the spec world. We merged a whole heap of stuff in the last spec meeting. I am yet to catch up with implementing all of that. A lot of it is low level but some of it is pretty cool. [Channel types](https://github.com/lightningnetwork/lightning-rfc/pull/880) went in. What happens at the moment, when you can connect to a new node you have features and you figure out what channel you are going to get by what features you support. If you both support anchors you are going to get anchors. If you both support static remote key you are going to get static remote key. If you both support anchors with zero HTLC fees that is what you are going to get. But increasingly there are cases where you might want to say “I know I support this but I don’t like it. I will support this feature if you want it but lets open a channel of this type.” Introducing explicit channel types in open is a thing everyone really wants particularly as we add more things. You don’t want to be cemented in. Some things are obvious improvements but other things are more questionable. Hence channel types, “Here is the channel type I want” and they reply and say “Yes this is the channel type we are making” and away you go. Everyone is hoping that that will roll through the network really fast and become the new normal. 

It is useful for us because we have a proposal for [channel upgrades](https://github.com/lightningnetwork/lightning-rfc/pull/868) that we [support](https://github.com/ElementsProject/lightning/pull/4532). That uses the same kind of channel type thing where you go “I would like to upgrade to this channel type”. We could do this for anchors. It can’t upgrade obviously to Taproot because that requires you to create a new funding transaction. Some upgrades will require splicing. I have been working through that. Matt Corallo finally got onto to implementing onion messages and pointed out some things that are suboptimal which I wish he had done 6 months ago. There is a new onion message format and we will support both. I have a call with him in 4 hours going through the nitty gritty of how that is going to work. He is implementing it in LDK. They seem to really want offers so he is going through the pain of implementing the drafts. The first thing to do is implement onion messages which requires the blinding stuff that t-bast did. This is the problem. There is a draft spec for blinding and then you have to do onion messages on top and then you have to do BOLT 12 on top of that. There is this unsteady tower of spec proposals that he is complaining about at the moment. No one has written any test vectors for any of them because you don’t want to do that until you are finished. I expect to get an earful when I talk to him in a few hours about the state of that. That’s good, I’m reimplementing some of the onion message stuff. It means we’ll have to send all the new onion messages for a while. We will send twice as many as we need and it will be a bit messy. We’ll probably have one release transition. People running experimental stuff like offers tend to upgrading fast. I don’t want to break them again but we will be sending both and you ignore whichever one you don’t understand. In 2 or 3 months time when the next release comes out we will drop the old ones and everyone should be good. Those of you who are on experimental you are on an upgrade treadmill now, sorry. But the resulting spec is better. Onion messages are now less distinguishable. It turned out the way the spec was written, you could tell by looking at an onion message whether it was the initial send or the reply. They looked different which is just dumb. It was just the way things fell out from the design. That was Matt’s point, we should make them all the same even though it is gratuitous. He is right and that is what we are changing. None of the math is changing, just the packet format is changing a bit. Everything else on my to do list has slipped until that happens. I don’t quite know what is going to make it in the next release but I’m glad we have 4 weeks which is far enough away for me to still fantasize about all the things I could do in that time and how great it is going to be. 

It is going to be great. 

Yeah it is going to be a good release I think.

On the channel types, anchor outputs will be the first channel type upgrade? I saw Z-man [said](https://bitcoinops.org/en/preparing-for-taproot/#ln-with-taproot) said anything Taproot related is like 4 years off.

That’s a bit pessimistic. There is a lot of stuff between now and then. Anchor outputs, I have tested upgrade with anchor outputs at the moment and it seems to work. But it is a draft implementation on top of a draft PR so it is still TBA. To do Taproot upgrades will actually require a splice or a channel close and reopen. A splice is the neater way to do it. When you do a splice you say “This is the channel I want after we’ve spliced”. You would now do a gratuitous splice just in order to get Taproot. You could do other things as well. We will need to do something like that to do a Taproot upgrade. Would you bother upgrading? Maybe eventually, eventually people will start going “We are dropping the early SegWit stuff, everyone is going Taproot”. At that point you will be forced to splice or die. I agree with Z-man on that, that’s at least 4 years off before we completely are in all Taproot world. I don’t know if there will be any pressure to upgrade your channels immediately. I don’t think there is a compelling reason. There is a compelling reason if you are opening a new channel, it is much more private and a greater anonymity set but I don’t think there is a compelling reason to upgrade a channel today.

In his Optech [blog post](https://bitcoinops.org/en/preparing-for-taproot/#ln-with-taproot) Z-man split it between P2TR channels and PTLCs. There isn’t the motivation to work on P2TR channels until ANYPREVOUT is available, got to be at least 2 years, but for both of those you can’t use the channel upgrade thing right? With PTLCs you could?

PTLCs you could, with PTLCs you don’t even need to upgrade the channel. If you both negotiate to say you support PTLCs you could add a PTLC. PTLCs are both easy but hard. They are easy because if you and I connect and you say “I support PTLCs now” I can send you a PTLC and we are all good. Unless you have a whole path of PTLCs they are completely useless. We will have a PTLC partial upgrade and then at some point people will start going “We are dropping HTLCs.” It is all PTLC world, wallets will only support PTLCs and eventually you will have nodes that go “I don’t even know what a PTLC is”. But that is far, we will be driving flying cars by that point. 

When you said the Taproot stuff is more private were you talking about the PTLC adoption? Right now when you have a public channel you tell everyone where your public channel is and they can go find it and verify it for themselves. Are we going to get rid of that for Taproot?

No we are going to have to prove that… I went back around this about a week ago, is there any other way to prove that you have a channel without saying which channel you have? That would be nice. The reason we want you to prove a channel is fundamentally anti-spam. You can’t say “Hey there’s a channel here”. But you can do weaker proofs. At the moment you literally prove that you control a UTXO between the two of you. It naturally gets weaker with Taproot. All you can prove is that you own a UTXO, you can’t prove that it is a 2-of-2 because it is MuSig. You can say “There is a UTXO and I can prove I control it”. We could loosen it in other ways. We could say “In order to register your node you have to prove that you control a UTXO but not the individual channels”. Or your first 8 channels are free, prove one UTXO per 8 channels, things like that. We could loosen the mapping up so there isn’t this direct mapping between what is going on on the Lightning layer and what is going on underneath. We could do this. It would make chain analysis harder. People are starting to do cross chain analysis now so it might be nice to weaken it. But it weakens our anti-spam properties. Suddenly for one UTXO you can spam 8 channels. Some of the zero knowledge proofs, saying “I prove I control a UTXO in this range” don’t help because they are replicable. I can create as many of those proofs as I like. I can have 1 UTXO and create a million proofs that I own it. You can’t distinguish which one it is as far as I can tell so you can’t use it for anti-spam. That doesn’t help us unfortunately. We can weaken our anti-spam properties but that is about all we can do. I think we are going to do the most straightforward thing which is you prove that you control a signature on the UTXO and you publish a UTXO as now. But it is not a foregone conclusion, we could go for something more sophisticated. Some kind of node registration where your first channel you need to prove and after that you don’t have to give short channel IDs perhaps. It depends on how critical people think that is. My original thinking was for routing nodes you don’t care about privacy so much. That is somewhat true but it still annoys me that we link the onchain with the Lightning side. You are open on your whole UTXO set, this has proven to be a privacy problem and continues to be a privacy problem, perhaps we should attack it differently. 

One thing which can be improved with very strict coin control and possibly Taproot, when you open a channel you would need to advertise that it is a funding transaction of that public channel but not necessarily which peer is the funder. If it was through a coinjoin for example or funded an external wallet, not from a previous channel close, then the capacity of the node would increase but you wouldn’t know if there are actual funds on there or not. If Taproot can improve on this you wouldn’t be able to see from the opening… You have a wallet with a known owner or a UTXO or a known owner, it would be sent via an onchain payment to someone or it would be a channel open. Taproot probably doesn’t help as it is now. It would only help if it was through coinjoins in the meantime which is out of the scope of c-lightning I’m sure.

This is more thinking from a spec level what we should be doing. I am tempted to say we should divorce ourselves from directly proving… perhaps proving any UTXO is sufficient. “I control a UTXO” and this lets me use the Lightning Network. Maybe we have some kind of sizing where we are going to assume 100,000 sats per public channel. If you can prove n x 100,000 sats are under your control you can advertise this many public channels or something. Maybe round up, if you only prove a tiny UTXO you can still publish one channel. We no longer have the ability to detect if you are advertising a giant channel and you don’t really have one. But I don’t think that is a huge loss. You’ll find out pretty fast.

It sounds a bit like fidelity bonds in Joinmarket. Proving those and then you can do other things.

Yeah, definitely. It is a model that has been used elsewhere so maybe that is something we should go to. I’ll talk to the other implementations at the spec level. It is an opportunity because we are going to have to change something. At the moment we literally prove that we own a 2-of-2 and that is changing with Taproot. Maybe we do something smarter while we are changing it anyway. I like getting more privacy for free without having to do anything fancy.

I won’t ask Christian about whether he agrees with Z-man’s assessment that P2TR channels only come after ANYPREVOUT. I’ll leave that for another call. He is deliberately muted, Z-man has muted him. 

