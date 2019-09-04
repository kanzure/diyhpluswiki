Group updates

# Alice abuses verifiable credentials

We restricted our scope to a manageable slice of the problem we think we can realistically handle. It's been very productive. We made an outline together, and now everyone can work on individual parts of the paper. I think it's been great.

# Blockcerts v3

We categorized what we wanted to write about and work on and kind of going back and looking at the history of blockcerts and specific things that were added, and an extension that were added, and looking more closely at the verifiable credentials schema. Kind of more so on the history than an outline approach. No obstacles really, it's more just getting in the right mindset of things and then individual research tasks and then we can sync back together and compare notes.

# Proof of personhood

We're moving along okay. We have an outline and a table of contents. There will be challenges in finding the solution. We're doing fine, I think, so far. We had some good references and finding good documentation and stuff. So that's nice. We're really challenged until we know the solution.

# Shamir secret sharing

The big obstacles we've been dealing with are terminology and naming. Share is a noun and a verb. We're no longer using share, now we're using shard. We spent half the morning making a glossary and fixing it. Make sure you have your glossaries setup. The biggest aha was that we kept on doing it from the perspective of the person dealing the shards, but we were forgetting the person who is the custodian of those shards- the person who receives those shards. We need to work on the UX of what it means to collect your 100 shards which are all sent everywhere. Once you have a deck of shards, what do you do with it? Don't focus on what you did in the process; what were the insights, and what were the obstacles?

# Presentation request

Proof of response is not enough, that's not personhood. We're looking into the different approaches for presentation-request. We're looking at those approaches, both in terms of -- against credentials that are held... W3C credentials... the hyperledger approach.. supplied to us... encouraging thing we're finding here is that msot f people have independently, for the interaction, or whatever they were thinking -- and taking this information and -- most people are -- and .. the difference between things are.

# BTCR Continued

.. some issues with the ... could resolve... through the ...

# Concern for Minorities

No particular obstacles today. We're doing a ledger review. We're going through all the previous rwot papers having to do with web-of-trust or reputation.

# How cooperation beats aggregation

The insights were that-- one of the goals was to find ways that cooperative network effects would arise out of lowering trust transaction costs. We started defining some of those. It includes not just onboarding costs but verification costs, consent, contract costs, end-to-end data transfer costs, and provenance costs. These are all areas where a decentralized identity platform would help. We're trying to flesh out those ideas and better define a meta-platform in terms of its characterization.

# DID resolution v2

We were wondering how to handle a fork. It's actually surprisingly hard. Either you have to change the identifier, use url query params, and being able to define as a URI which of the definitive source of the DID document. So if I'm trying to resolve the identifier to an actual DID document, how do I know which one is useful and what are the implications on verifiable credentials using DIDs? It's an unresolved problem. We opened a github issue on that.

The approach that we realized was that the method has to specify it, because the different ledgers have different types of things. I didn't feel like that was fully resolved, but at least it was going in the right direction.

# DID holochain

This is team Holochain. We met with some folks at lunch and got some help reviewing our DID resolver method for holochain resolution. I think we got some questions answered. We still have some questions about crowds. It's in pretty good shape. Appreciate the help, Marcus and others.

# How to design a good reputation system

This has merged with the other reputation group at the moment. We had broken them out. We got together and that green board has the answers. We had some nice insights. We realized that reputation system is not something that makes sense to design. You need to start with the actual usage that you want the reputation to support and then start with an experimental design. So you look at the actionable outputs, what are the actions and the kinds of decisions you want to make, and if you want a complex change to the terms of engagement like changing the terms of the loan like the interest rate then you need a richer set of information than just a value score for an actor. You start with an action, and then you start with the output and we look at how we're going to pull information from the standard reputation metrics to that whole latent data graph and all that social information out there. This gives us our data points. These data points are very corrupted. Your github commit history is not easily quantifiable. Your stuff like ebay or amazon numbers have a lot of confusion in where those magic numbers come from. We want to break that out into different dimensions, normalize it, and then spread that information out, and then appropriately weight and combine that to support that output. We merged with the other group to start with some use cases. We plan to write that up tomorrow.

# Issuer independent verification

Collaboration is the inspiration. The distractions is the ... the detail is that our group started with 5 and we recruited a couple more, so now we have 7. We have made a lot of progress on the paper. We have the abstract, table of contents, and we're actually working on the detail like 2-3 pages. We have good progress on the writing. On the collaboration part, we got together with Manu's team to understand a little bit about datahub. We're doing an open verifier, so we needed to know the methods for accessing data. We were also talking with a group that were looking at attack vectors for verifiable credentials and we learned from some of their issues.

# Minimum viable protocol for decentralization

We started the day with discussions. We tried to land on terminology and where we wanted to go. We had our first interview. We got a lot of good information and landed on our first flow for SMS and how that will work. We think we're going in a good direction. A lot of good positive work.

# The real problem with centralization

We have created an outline. The main obstacle has been trying to prevent scope creep. We're dealing with complex adaptive systems and trying to spell that out in significant detail. Is there a particular... that stands out for you? The topic isn't well defined and we're feeling our way through it.

# Rubric for decentralization of DID methods

I think we had a pretty productive day. We had two structural inspirations. One was, adopting Scott David's framework for governance of rulemaking, operations and enforcement. Then we reorganized the work we have done into that. It felt pretty good. The other thing was coming up with a DID representation for some of these criteria to have multiple factors but you want to compare across multiple DIDs. So we came up with a visual representation to scan through and understand how it fits with your criteria. That was pretty cool.

# Reputation spec use case: p2p lending

I don't know if we have any particular insights to share. We spent the day mostly on narrowing down various concepts. We looked at other trust-based p2p lending systems. Obstacles is that we have a fluid group and I'm not sure who is in it. We spent too much time talking and not enough time outlining.

# Secure data storage

Things are going pretty well. We have some use cases, deployment topologies, requirements. Everything is shaping up pretty well. One of the things that we-- one of the insights was that teasing apart when we talk about secure data hubs what the server's responsibilities are and what the client's responsibilities are, like replication and data sharding. We avoided ratholing like 4 times, which was good I think, because by the end of the day we were able to kind of, approach things in a more structured way. By giving time to percolate things in the back of our minds, the thing that seemed like they would be big arguments, by the end of the day became just a fairly quick discussion. The challenge is that we have a lot of content to write, and we'll make some hard decisions about what to cut tomorrow. When it gets done, it can get placed directly as a specification. We also did a good survey of the landscape, like sovereign pods, nexcloud stuff, tahoe, datahubs, etc. Tahoe came up multiple times.

# Secure user interfaces

The two biggest insights were to be able to move beyond just kind of an abstract discussion about what the principles were, to be able to get engagement with everyone and to even fulfill our goal of being able to be something where the secure interfaces come out of intuition. We needed to have the interface drawn on the board. An insight of also what I think I would do in the future if we started fresh; we realized we drew out Mastodon's existing interface, and we started making changes, but we should have drawn it out in one color as-is, and then make changes in separate colors so that it would be more clear. I think we got through all the stuff of like how what needs to be done, what the principles are, and as a group we managed to pretty well understand what the components are to a secure user interface. The big obstacle is being able to distill all of that into a day and a half for a document.
