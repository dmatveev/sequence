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
