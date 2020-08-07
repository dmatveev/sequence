Class {
	#name : #SeqSceneTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqSceneTest >> testBasicScene [
	| cam vis scn |
	cam := SeqBlock named: 'Camera'.
	vis := SeqBlock named: 'Visualization'.
	cam >> vis.
	scn := SeqScene startingWith: cam.
   self assert: (scn includes: cam).
   self assert: (scn includes: vis).
]

{ #category : #tests }
SeqSceneTest >> testBasicScene2 [
	| cam pro vis scn |
	cam := SeqBlock named: 'Camera'.
	pro := SeqBlock named: 'Processing'.
	vis := SeqBlock named: 'Visualization'.
	cam >> pro >> vis.
	cam >> vis.
	scn := SeqScene startingWith: cam.
   self assert: (scn includes: cam).
   self assert: (scn includes: pro).
   self assert: (scn includes: vis).
]

{ #category : #tests }
SeqSceneTest >> testBasicScene2Tail [
	| cam pro vis tails |
	cam := SeqBlock named: 'Camera'.
	pro := SeqBlock named: 'Processing'.
	vis := SeqBlock named: 'Visualization'.
	cam >> pro >> vis.
	cam >> vis.
	tails := (SeqScene startingWith: cam) tails.
   self assert: tails size equals: 1.
   self assert: (tails includes: vis).
]

{ #category : #tests }
SeqSceneTest >> testBasicScene2Topo [
	| cam pro vis topo |
	cam := SeqBlock named: 'Camera'.
	pro := SeqBlock named: 'Processing'.
	vis := SeqBlock named: 'Visualization'.
	cam >> pro >> vis.
	cam >> vis.
	topo := (SeqScene startingWith: cam) seqTopo.
	self assert: topo size equals: 3.
	self assert: topo equals: { cam. pro. vis } asOrderedCollection 
]

{ #category : #tests }
SeqSceneTest >> testBasicScene3 [
	| cam pro vis dis net tails |
	cam := SeqBlock named: 'Camera'.
	pro := SeqBlock named: 'Processing'.
	vis := SeqBlock named: 'Visualization'.
	dis := SeqBlock named: 'Display'.
	net := SeqBlock named: 'Network'.
	cam >> pro >> vis.
	cam >> vis.
	vis >> dis.
	vis >> net.
	tails := (SeqScene startingWith: cam) tails.
   self assert: tails size equals: 2.
   self assert: (tails includes: dis).
   self assert: (tails includes: net).
]

{ #category : #tests }
SeqSceneTest >> testBasicSceneTail [
	| cam vis tails |
	cam := SeqBlock named: 'Camera'.
	vis := SeqBlock named: 'Visualization'.
	cam >> vis.
	tails := (SeqScene startingWith: cam) tails.
	self assert: tails size equals: 1.
	self assert: (tails includes: vis).
]

{ #category : #tests }
SeqSceneTest >> testSceneRecursion [
	| cam vis |
	cam := SeqBlock named: 'Camera'.
	vis := SeqBlock named: 'Visualization'.
	cam >> vis >> cam.
	self should: [SeqScene startingWith: cam] raise: SeqCycleException .
]

{ #category : #tests }
SeqSceneTest >> testSceneRecursion2 [
	| cam pro vis |
	cam := SeqBlock named: 'Camera'.
	pro := SeqBlock named: 'Processing'.
	vis := SeqBlock named: 'Visualization'.
	cam >> pro >> vis.
	cam >> vis.
	vis >> cam.
	self should: [SeqScene startingWith: cam] raise: SeqCycleException .
]

{ #category : #tests }
SeqSceneTest >> testSingleItem [
	| cam scn |
	cam := SeqBlock named: 'Camera'.
	scn := SeqScene startingWith: cam.
   self assert: (scn includes: cam).

]

{ #category : #tests }
SeqSceneTest >> testSingleItemTail [
	| cam scn |
	cam := SeqBlock named: 'Camera'.
	scn := SeqScene startingWith: cam.
   self assert: (scn tails includes: cam).

]
