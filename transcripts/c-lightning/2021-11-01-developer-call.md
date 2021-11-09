Name: c-lightning developer call

Topic: Various topics

Location: Jitsi online

Date: November 1st 2021

Video: No video posted online

The conversation has been anonymized by default to protect the identities of the participants. Those who have expressed a preference for their comments to be attributed are attributed. If you were a participant and would like your comments to be attributed please get in touch.

# c-lightning v0.10.2 release

<https://medium.com/blockstream/c-lightning-v0-10-2-bitcoin-dust-consensus-rule-33e777d58657>

We’ve tagged RC1 to get people testing. The testing found 2 regressions, both related to the database handling. One is Rusty’s crash outside of a transaction. I quickly wrapped that in a transaction conditionally whether there is already one or not. The other one is when we do our switcheroo to remove columns from a table that SQLite requires from us. That apparently de-syncs the counters on auto-increment fields. We ended up with duplicate entries in the database itself. That also has a quick fix now. Yesterday I tagged release candidate 2. If all goes well we should have a final release sometime this week.

Do we use auto-increment fields in the database?

We use auto-increment fields whenever we auto-sign a new ID in a column. Most of our tables actually have a ID column that is auto incremented. Whenever we do a big serial or sequence then that is one of these sequences that can end up out of sync if we do our rename, drop and copy into.

I am going to have to look back through the PR because I’m not sure how that happened. I would assume that it would keep incrementing from where it left off.

What you do is you rename the table, create a new one with new counters and then you select and insert into the new table and drop the old one. When you insert with values pre-filled the sequence doesn’t increment itself.

But that is only one time? Say it was 5, you copied across, create a new table, you copy it back, it is still 5?

The sequence is still counting from 1.

How do you fix it?

We fix it by manually setting the value to the maximum plus one of the column.

Wouldn’t the select statement have populated it with that? I will look through the code.

The insert with values in that column will not call the increment on the sequence. That is the collision. 

I’m not sure I get it but I will look at the code until I understand it. I have a hack that does some database handling, helpers to delete columns and rename columns. This is easy in Postgres and really hard in SQL. I would like to fix that case rather than have us continuously stumble over it. 

# Individual updates

I just opened a maximum size channel on signet to my friend who I am teaching c-lightning to. We will have new students soon. 

I was thinking I have to fire up my signet node and get that working. I have been running a signet Bitcoin node for a long time but I haven’t actually fired up c-lightning. Maybe after I upgrade my machine. I run my nodes under Valgrind and it is very heavy.

I am running the latest version of c-lightning on signet, testnet and mainnet. It is all running very well. 

There seems to be an active signet community which is nice. 

The next Raspiblitz release will likely be in the next 2 weeks. We have a few bugs ironed out. We added c-lightning, added parallel testnet and signet. We updated the image, there were some pressing bugs. I have updated to c-lightning 0.10.2 RC1 and RC2 from the menu so it works with the Raspiblitz deployment, the updates are working. That’s available for everyone even if you don’t update the image. That will be coming with the next release of course. My smaller size routing node, I didn’t find any issues which is good I guess. Another interesting development, waxwing has used [c-lightning onion messages](https://github.com/JoinMarket-Org/joinmarket-clientserver/pull/1000) in Joinmarket. That’s an exciting thing to look at and explore. Also there is a proposal to use actual payments later on for the coinjoin fees paid to the makers but that is far off. It is a more involved, complicated implementation but the onion messages to be used in parallel with the IRC coordination is quite exciting. That just uses a couple of Lightning instances. That is the other thing I have been looking at.

I agree, that is really exciting, I look forward to the Joinmarket integration. That’t pretty sweet. Lisa is always on about people not doxxing their channels and their nodes.

I don’t think we need channels to use onion messages. Those would be just ephemeral nodes that use the layer for communication. It will be exciting to see how it functions with the same machine running a c-lightning node and at least one more as a taker as well. We will see how much pressure it puts on the Lightning Network itself. These messages, all the peers you want to communicate with will be running the same version so I don’t know if there will be any hops involved at all really. There could be but the hops will be between peers which are also running the same kind of Joinmarket software, a Joinmarket cluster on Lightning. It shouldn’t affect the rest of the network as I see it. Same with the payments together, that involves liquidity issues so there is far to go with that.

If you are doing a coinjoin you are obfuscating your UTXO set which is definitely a direction we want to head in.

What is the release cadence of c-lightning? Is it the same as Core?

It is every 2 or 3 months. 

For a minor release?

We don’t really distinguish. I’ve actually been thinking about switching us to a dated release system. 21 dot whatever and 22 dot whatever rather than justifying a major or a minor bump, that’s an arbitrary last minute decision. We look at the list and go “I think this feels like a 11 or something”. I don’t know that in retrospect they’ve been justified. The important thing is to get a release out, the number is secondary. We’ve generally tried to go for a fairly rapid release cycle. The idea is that the RC drops on the 10th of whatever month, a 2 month release cycle. But then often in practice if there are a couple of RCs it can be 3 weeks before the final drops. Now we’ve only got 5 weeks until the next RC, is that too tight? It has been 2 or 3 months and it is been up to the release captain to decide what the cadence is going to be. Sometimes it has been longer than that but we do try to keep a fairly regular cadence. If we went for date numbering it would become more obvious when we’ve missed our cadence. But nobody cares about version numbers. Version names, they are important (Joke) but version numbers, bigger numbers are better generally. I think date based is probably something we should switch to at some point.

Block height based?

It has the advantage of neither clarity nor… At least it only goes up so that is good.

But shorter than dates.

Less memorable too for most of us. I don’t reminisce generally about block 400,000 or whatever.

I have been a little lazy the last 2 weeks, just some rebasing of my 2 PRs I have open. And a little progress on the one where we tell our peer his remote address. Now this information is filtered down to the Lightning daemon in order to be used there because connectd can’t use it, it doesn’t know the other addresses. These will be merged after the release. For the DNS one we need another implementation to pick it up because I think no one is working on that. I think Sebastian is working on the remote address part on ACINQ.

Michael is not only modifying c-lightning but he has also been advocating on the spec side to have this spec’ed because this is a change to the messages we send out. The idea that you’ll tell the peer what you see them as. “We see this as your IP address” where that information is available and useful. This is something that Bitcoin Core does now which I hadn’t realized. They used to use myipaddress.com or something. You used to reach out to that to get the IP address of your node. They gossip their view I believe. “Hey this is what I see you as”. If enough of your nodes tell you that seems to be your IP address.

I think we should also maybe think about adding a UPnP library or something like that. If the router is enabled then we can use it. Bitcoin Core does it?

Did it, had a security hole in it, dropped it, I think reenabled it. There have been issues around UPnP, it is a mess. I also tried out this library a couple of times, not that great. It seems to have some bugs so maybe reimplement it, I don’t know. It doesn’t work very well for all routers, maybe for a certain subset and certain devices it fails.

I think the argument is that it is better than nothing. It is nice if you have a IP address. I like the autoconf nature, I like the fact that if people manually override things we should respect that but if people run c-lightning out of the box then it should probably believe consensus when it talks to peers and they see a IP address. Ideally it should try to punch a hole so that works.

Maybe I’ll check the Bitcoin Core node about the UPnP stuff, I am pretty sure they did well enough.

We should just steal their code, that’s an excellent idea.

Or we could tell the Bitcoin daemon to open the port for us if they already have it (Joke)

If you think changing the spec is hard try getting a new RPC call into bitcoind. Definitely looking at what Bitcoin Core is doing there would be nice. Just knowing our IP address would be useful so that we can gossip that. I’m not clear what the defaults should be here. If they don’t set it up and they are behind a private IP address, at the moment we won’t advertise any addresses for them. If we believe we have an address should we start advertising in the hope that people can maybe reach us on that IP address? Are there issues there? People may have been relying on the fact that wasn’t…

I think we can broadcast one or two addresses where we aren’t certain, just try it. As long as we don’t broadcast 10 addresses or more it is not a big deal.

You have to have a public channel to advertise your node anyway. By definition if you’ve got a public channel you are at least announcing your existence. I just worry about people who didn’t want to advertise their IP address. Certainly if they have any Tor things enabled I wonder if we shouldn’t advertise their IP address. We are going to have to think carefully about changing behavior in those cases. We can think about that offline.

What PRs are we talking about?

[4829](https://github.com/ElementsProject/lightning/pull/4829) is the DNS one and the other one is [4864](https://github.com/ElementsProject/lightning/pull/4864), that one is still in draft. It is working for sending and reading this information but it is not doing anything useful yet so it is a draft.

Last week I worked on some internal Blockstream stuff. I have also been updating our [guess to remote stuff](https://github.com/ElementsProject/lightning/pull/4893) to include anchor outputs. Someone recently fried their node and didn’t have a backup. I am on working on recovering stuff. They weren’t able to use our [existing recovery tools](https://lightning.readthedocs.io/BACKUP.html) to recover any of the funds they had put into lease channels on either side. The reason for that is those use anchor outputs and our tooling did not take anchor output scripts into account. I’ve updated those and created an extra tool. The change to anchor outputs changes the `to_remote` from a public key hash to a script hash. Now you need to know what the script is. It used to be you had a pubkey, it is pretty easy to use existing wallet software to spend any output using a pubkey, private key, that is pretty straightforward, a lot of wallets support that workflow. They don’t really seem to support the script hash thing so I added an extra tool, I haven’t tested it yet and I’m not 100 percent sure it works. In theory there is now a tool where if you give it a PSBT it has the output you want to spend and all the metadata associated with it. This tool will sign that input on the PSBT that you provided and return a PSBT with the proper scriptSig information filled out so you can spend it. I trust it signs correctly and it will do whatever but I haven’t tested that it spends correctly. I pinged the person who had the problem. I need to talk them into giving me their private key data for the output of the channel that I had with them. I can just send it to wherever they want. That is up in a PR.

When I was in Zurich a few weeks ago I spent some time talking to Christian about how to update our accounting stuff. I would really like to get an accounting plugin done soon. I did some rethinking about how we do events, it is an event based system. Coins move around, c-lightning emits an event. I am going to make some changes to how we are keeping track of things. I think the biggest notable change is we will no longer be emitting events about chain fees which kind of sucks. There is a good reason to not do that. Instead the accounting plugin will have to do fee calculations on its own which I think is fine. That is probably going to be the biggest change. Working through that today, figuring out what needs to change. Hopefully the in c-lightning stuff will be quite lightweight and then I can spend a lot of time getting the accounting plugin exactly where I want it. That will be really exciting. I am also going to be in Atlanta, Wednesday through Sunday at the TAB conference. I am giving a [talk](https://www.youtube.com/watch?v=mVihRFrbsbc&t=6470s), appearing on a panel and running some other stuff. I will probably be a little busy this week preparing for the myriad of things someone has signed me up for. If anyone has suggestions about topics to talk about you have 24 hours to submit submissions if there are things on Lightning you want to hear about. 

Something to get rid of next after we’ve got [rid of the mempool](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019572.html).

That was brave. I think it is great. I think you are wrong but that is ok. 

I think it is ok to be wrong.

It was a productive discussion.

It was very interesting actually.

I have had a bunch of conversations with people around it about interesting things. I think it sparked a lot of really good discussion and rethinking about exactly what the mempool’s purpose is. I have been meaning to write a follow up post to the one I sent to the mailing list summarizing everyone’s takes. Some of the arguments I was expecting to see but didn’t.

If people don’t lynch you occasionally you are not doing your job properly.

Someone posted on the mailing list, is someone moderating this list? How is this allowed to be posted? Are they even reading the posts?

Didn’t you know the mempool was part of Satoshi’s doctrine, you can’t question it (Joke). 

There have been some pretty good discussions in a private chat I’ve been in about changing the RBF rules. This has been headed up by Murch and Gloria. I have been talking to them pushing for a certain angle on how those rules get changed. I think I’ve managed to convince at least one person. We are looking at making pinning less possible. I don’t know if I want to talk about that though.

RBF pinning is one of those obscure black art areas. People just want you to fix it, they don’t want you to talk about it. That’s the response I’ve had. “That sounds really complicated, tell me when it is fixed”.

Pinning is the one I always forget, the setup is not complicated but there are definitely a number of assumptions you make before your transaction is pinned. I need to remind myself of that. I could talk about accounting but maybe it should after I’ve built it.

Accounting is a big hole unfortunately that we don’t have a really great answer for. It is nice to have thorough blow by blow, here’s where all your money went. Mostly people ignore fees or sum them as if they happened all at once but in a number of scenarios like filing your tax you should be annotating all of the expenses when they happened approximately.

There are a couple of reasons why I like accounting. One way of looking at it, really what I’m working on is a data logging project right now. I am making c-lightning such that it will effectively log all of the data movements. That is really nice for accounting when you have taxes etc but it is also really nice for control or making sure you know where your money is. I talked to the ACINQ guys pretty briefly about how they were doing accounting when I met up with them a few weeks ago. They are doing more checkpoint style. There are a couple of ways you can do it. You can do checkpoint style where you take a snapshot and you compare it to previous snapshots and see what’s changed. The approach I am taking is emit events as we go. There will probably have to be a checkpoint emitted at some point, a checkpoint will be one of the emissions but ideally you’ll have more of a realtime log of events that are happening. The problem is if you have two checkpoints and something happens between them, you have to go back and figure what happened in between. If you have a log of events in theory you should be able to look through the events and see what happened, you don’t get surprises between checkpoints.

There is the meta problem of lack of finalization. Nothing is final ever in Bitcoin.

One of the ways we are going to kind of get around that is I am going to push some of the finalization accounting onto the plugin itself. c-lightning is going to emit events and then to some extent it will be the responsibility of the plugin to keep track of when things are final.

That makes sense. 6 blocks is final(ish) and 100 blocks is forever.

But that means the plugin needs to have a block store of its own that it keeps track of. It is not beautiful but I think it will be fine. 

Did you have a prototype of an accounting plugin before? It didn’t make it to the plugin repo?

There is the data logging aspect of c-lightning and I started working on a plugin and ran into problems. The problems I ran into were the fact that c-lightning replays events. One way I am going to fix it is by making it such that the accounting plugin expects duplicates and deduplicates them. There is some complicated stuff that I had to do but there were some things in the original event emissions that we were doing that I don’t think are sustainable long term. Especially now that we have dual funding and there are multi funded transaction opens and splicing on the roadmap soon, fingers crossed. All those things make some of the assumptions that we were making about where fees are going and who owns certain inputs and outputs on a transaction are no longer valid. I am revisiting some of those as well. No there hasn’t been a plugin, there has been events being emitted but as far as I know no one is consuming them.

That’s good because you are about to break them all.

Yes that’s correct. The data format is fine. I thought I was going to have to change the version, they have a version in it already. There is a version number in the data thing. I was looking at it today, I think the data is fine, it is just when we emit them and for what purpose, what events we are emitting is going to change.

I stumbled across it in the outpoint rewrite.

vincenzopalazzo: In the last two weeks I have worked on some c-lightning PR review. Also I started working on an issue where we accepted opening a channel with an amount lower than the minimum amount that the other side would accept. I think we need to query the gossip map in some way to get this information. I think we miss this check where the amount that we are requiring to open the channel is greater than the minimum than the other side would accept. To get this information we need to query inside the `fundchannel` command to get the information from the gossip map. I am not sure about this. 

They do not have a generic way of gossiping to say what their minimum channel size is which is unfortunate. It has been a common request. We didn’t do it because there is a whole heap of other conditions it could have on things. What happens is you get an error back which is a “human readable” code to say I didn’t like things. There is no reliable way of telling it. The human operator reads the code and says “It must be this.”

I think at some point I was working on a spec proposal to send your minimum channel in the init message. There is an init TLV and that way you have it at open. It is not gossip necessarily but when you connect to a channel you immediately get the data, I don’t know.

There are other things you might not like. There was also the proposal to have errors specify what they were complaining about and a suggested value. That would also address this and a pile of other things. You could say “This field should be this” and that would be “Here’s your minimum value” in this case. We cover other cases where you don’t like something that they’re offering you. In a more generic way, perfect is maybe the enemy of the good here, maybe that is why it never happened. “It doesn’t cover all the cases”. That maybe it. For the moment we are still falling back to human readable messages which is terrible. You could hack something in to try to interpret the different things that LND, LDK, us and other people say and do something smarter but good luck.

Just tell them upfront. Whenever you connect to someone, tell them upfront in the message that is formatted and then you don’t have to worry… I guess you’re saying there are other reasons it won’t open but I think the min channel size is a really common one.

Min channel size is actually really common. I do like the error proposal where you specify exactly what is wrong. It was a proposal, I don’t know if it went anywhere. At risk of making you do a lot more work you could perhaps look at that. They don’t broadcast any information where you can immediately tell what the channel size should be. Sorry, you would expect it to work the way you say but it doesn’t.

vincenzopalazzo: I’ve finished my first version of the Matrix plugin with the server. In the next week I will publish the website with some fun information. I am relying on the information that I am receiving because I don’t want to make a real server with authentication, I want someone to put the data and I verify this data is from the node that sent me this information. The things I am thinking about is to use onion messages. I receive the data, I get the hash to check this data and with the onion message I send back the message to the node that is the owner of this payload. “This is your data with a check on the hash” and I receive back ACK or NACK. I don’t know if this is the correct way to do it. 

I am a fan of anything that uses onion messages so I’m probably biased here. 

# Future possible changes to Lightning gossip

I did do a couple of things now I think about it. One was this idea of [upending gossip](https://twitter.com/rusty_twit/status/1449875010181484545?s=20). We are going to have to change gossip for Taproot. The gossip is very much nailed to the fact that with a channel you prove you control the UTXO and that is a 2-of-2. Obviously that is changing when we have Taproot channels, hand wave. We do need to rev our gossip in some way. The question is do we get more ambitious and rev it entirely. One thing I really dislike about gossip is that chain analysis have started to use our gossip to tie UTXOs to node IDs. This is fine for your public channels while they exist but of course that data leaks. When you spend those UTXOs in other ways you have now compromised your privacy. A more radical proposal is to switch around the way we do gossip and not advertise UTXOs directly for a channel. One reason to advertise UTXOs is to avoid spam. At the moment you have to prove that you control these funds in some way. It doesn’t have to be a Lightning channel but it does have to be a 2-of-2 of a certain form and you have to be able to sign it. If we go to a Taproot world and it is a bit more future proof, you control UTXOs and we believe you, then we could loosen it even more and say “You can announce a node if you prove ownership of a UTXO and that would entitle you to announce this many channels.” You just announce them “I’ve got a channel with Joe and it is this size max”. There needs to be some regulation on that. You need to limit it somehow but you can get a bit looser. You can say “Every UTXO that you prove that you own as a node you can advertise one channel plus 8 times its capacity” or something. You still have to expose some UTXO but it doesn’t need to be related. It could be cold storage, could be something else. In theory there are ways that you could get another node to sign for you, there are trust issues with that though. Would you pay them to lease their signature? What if they spend it etc? There are some interesting models around that. Unique ownership of a UTXO, there is some zero knowledge stuff that you could do here too, they are a bit vague. The idea that you prove a UTXO and lets you join the network, announce your node and then you can announce a certain number of channels. With the channels you don’t give away the UTXO information at all necessarily. A naive implementation would just do what it does now and a node advertises some UTXOs or its channels. You wouldn’t associate them directly so it would still be an improvement. There are downsides to this approach. One, there are arbitrary numbers. How many UTXOs? What sized UTXOs have you got to advertise? How many channels are you allowed to advertise? They are a bit handwavey. Ideally we would use [BIP 322](https://github.com/bitcoin/bips/blob/master/bip-0322.mediawiki), there is a proposed way to do signed messages for generic things but it has not been extended for Taproot. I’m not quite sure what that would look like. Ideally we would use the generic signed message system to say “This is how you sign your Lightning node announcement with your UTXO”. That piece is missing from the Bitcoin side. It would be nice if that BIP were finalized and we could start using that.

BIP 322, you would want that updated for Taproot?

And some consensus that that was the way to go. Then we would just use that. At the moment we have a boutique thing because we know it is a 2-of-2 and we produce both signatures. It would be nice to have a generic solution, use that BIP and sign your thing. That would be pretty cool. Whether we would only use the new gossip for Taproot, we’d probably need to do both. There would have to be a migration and everything else so we’d need real buy-in on the idea that that was worth doing. I am really annoyed with the Chain analysis people so it would be good to fix that and this is one way of doing it. Other people may have other ideas if we open up the way we do gossip. The other thing is I haven’t run the numbers on what it would do to our gossip size. Your node announcements obviously get bigger, you don’t have channel announcements anymore, you only have channel update. But you’ve lost the ability to do short channel IDs so now you need to put both node IDs in each one. But there are some compact encodings that we can use and things like that. I may be able to scrape some of that back and make it at least no worse than we are now. Maybe even a little better. That analysis has to be done.

# Individual updates (cont.)

On the c-lightning front I said I did the database stuff, I have that working. And ambitiously I looked at doing this wait API that we’ve talked about for a long time in c-lightning. There are a whole pile of events that we would like to wait for. We have a wait invoice already and a wait anyinvoice specifically to wait for invoices to be paid which is the most obvious thing. But there are other things that you might want to wait for, in particular with BOLT 12 rather than invoices being paid you may want to wait for invoices to be generated. And you might want to wait for payments that are outgoing. I’ve got this rough infrastructure, for every event that you can list effectively has a creation index and a change index. Then you can say “Wait for the next invoice change index” and it will say “Here’s the change”. Technically there is a deleted index too. You can say “Wait” and the wait RPC will return and say “Yes this is incremented, you’ve got a new change”. You also need to enhance the list things to list in create order or change order and presumably a limit, it will give you a certain number of paginations. That API where you have an universally incrementing index is really good to avoid missing events. It means your plugin can go to sleep, it comes back and it says “I was up to this event”. Then you’d get all the changes since then, all the changes that have happened. It doesn’t quite work if something is deleted in that time though. That’s the API it would be nice to head towards. It would subsume the wait invoice API and it would let you wait for almost anything that we have. That has been a long term thing, to work on that and have this generic wait API where you can wait for things to change or things to be created. Then you get notified when it does and you can go in and figure out exactly what happened. It is pretty simple to implement. It is both simpler to use and more efficient. A lot of things like Spark end up doing these complete lists and try to figure out what changed since last time they ran. It would be nice to get this kind of mechanism in place. There are a few twists, as I implement it we will see how it goes. That was a random aside, something I wanted to do for ages. There may be a PR eventually for that as well.

# Different networks and default ports

In Bitcoin Core when you run a signet node it runs immediately by default on a specified signet port. We use 9735 for any network in lightningd. Would it be possible to [switch to some network specific port](https://github.com/ElementsProject/lightning/pull/4900)?

I have done that in the Raspiblitz, following Bitcoin Core’s logic for testnet I add a `1` before the 9735 and for signet I add a `3`.

Maybe we should switch to defaults. It makes sense. In theory you can run multiple networks on a single port, I don’t know if anyone does that and our implementation doesn’t support it. But in theory you could have a node that runs both testnet and mainnet off of the same port. We have all the distinguishing messages, you can tell if you are only interested in this kind of gossip. I don’t think any implementation actually supports it. 

I had a problem doing that for Bitcoin Core when my node picked up some testnet block hashes and thought it was on a fork. I was quite worried for a moment.

We do distinguish them all, we will ignore them properly. In fact now we will hang up. It used to be that you could connect and you would both furiously gossip with each other about stuff and you’d be ignoring all the replies. “That’s the wrong chain, that’s the wrong chain, that’s the wrong chain”. These days in the init message we now send what chains you support and if there is no overlap between the two sets you just hangup. In theory you can support multiple chains at once, I don’t think it has been done.

# Q&A

Someone, I was talking to them, they opened a 20,00 satoshi channel to me. They couldn’t see it in Umbrel what the reserve was of the channel. Maybe on the command line but not in the web user interface. I showed them what’s the reserve, it was the same for both me and them. I didn’t have anything so I said “Now you send me 579 satoshis”. I still cannot send anything to you because it fills my reserve. We managed actually to send through me and so I did not lose any satoshis, I am routing for free. It was very interesting because I never realized these reserves of channels. Today I opened the signet channel with another friend, he filled my reserve and I was still not able to send him 20 satoshis. The reserve was 10,000 satoshis. I checked it was filled, the reserve was filled on my side and I had 20 extra satoshis, I couldn’t send them. It was reported in c-lightning. 

Who opened the channel?

He did.

So it is not a fee problem. If it says spendable msat is 20 you should be able to send 20 msats. File a bug report.

He said he was trying to route it. The router didn’t see him able to send that. I am quite sure you would be able to send it to the other side without routing it.

We have a test for this in our test suite that makes sure that you can’t spent 1 msat more and you can spend the amount that it says so it should work. It is quite a complicated calculation to see exactly how much you can spend. I can believe that there are issues with it. You should file a bug report.

I wasn’t trying to route. I was just trying to send to him. There was only one channel, he didn’t have any other channels.

The routing engine is invoked.

Probably because I was sending it and I have many other signet channels.

It should definitely work though. 

I’ll file a bug report.

Is there a difference if he uses keysend?

I opened another channel from another signet node to him, I did keysend and it worked. It was a big channel open from my side. It was with lnd on the other side. On mainnet he could spend every single sat.

On the ports conversation Core has just [merged](https://github.com/bitcoin/bitcoin/pull/23306) a relaxation of using the default port for mainnet. This seems to suggest they are moving away enforcing default ports, currently for mainnet but possibly for testnet etc as well. That’s just if you want to use a different port. You can obviously still use the default port.

I was running bitcoind, Bitcoin Core on different ports and it worked very well. My idea was that when someone plays with different networks on lightningd, they open that port and firewall and it is gossiped that this is their Lightning port for signet. Then they say “But actually this is the port I want to run the mainnet on”.

I think all of us have had the same problem where you have to manually move your other ones out the way. I am happy to follow the Raspiblitz convention and by default we should run testnet on the default port. It isn’t 9735, it is 19735 and whatever they do for signet. People can always play with it. Making the default sane is a win and probably something we should have done a long time ago. I look forward to your PR to change the default port.

I have a question on the encryption of the `hsm_secret`. If it is encrypted what would be the best way to detect it. As I understand there is no CLI error shown. What I am doing at the moment is parsing the logs to see the error but there could be a better way than that?

I don’t know what happens when it is wrong, what does it do?

It just says it is not available. If you try to call `getinfo` then it will just say it is not available.

So the daemon doesn’t start?

Yes.

Fatal.

It is fatal. Then you go to the error logs and it says that the password wasn’t provided or wrong password provided or something like that.

I think there should be something out to stderror. But also we should probably use a specific exit error code in the case... That would be a lot easier to detect. PRs welcome. It is a simple one but it is the kind of thing that no one thought about. Just document it in the lightningd man page. Pick error codes, as long as nothing else gets that error code it would be quite reliable. I think `1` is our general error code, `0` is fine. `1` is something went wrong, anything up to about `125` is probably a decent error, exit code for hsm decoding issues. As you say it makes perfect sense because it is a common use case. If you ever want to automate it you need to know.

Minisketch looks as if it is close to merge, if you want to use Minisketch for gossip stuff. You posted an idea before on the [mailing list](https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001741.html). I have an old branch that pulls in a previous version of Minisketch.

You did actually code it up as well? It was more than just a mailing list post? I didn’t see the branch.

I never pushed the branch, I never got to that point. Just played with it. Minisketch was really nice, the library is very Pieter Wuille, very sweet. Everyone should play with Minisketch just because they can, it is really cool. To some extent it is always secondary, it is just an efficiency improvement. There aren’t many protocol changes required. The whole network doesn’t have to upgrade to start using Minisketch gossip between nodes. 

When sending and receiving the remote address I use some struct which I get from the wire. In order to parse it I create the struct in C and say it is packed. I need to say it is packed so it is aligned and not something shifted in order to read it correctly. Is there a proper way to do this? Using some directive gcc that it is packed is not the correct way of doing this.

No it is not the correct way. You should be writing from wire and to wire routines for your struct. That specifies exactly what it should look like on the wire, Reading straight into a struct is generally a bad idea.

