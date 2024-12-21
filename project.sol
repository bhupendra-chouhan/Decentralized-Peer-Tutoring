// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PeerTutoring {

    struct Tutor {
        address tutorAddress;
        string subject;
        uint hourlyRate;
        uint hoursAvailable;
        bool isAvailable;
    }

    struct Student {
        address studentAddress;
        string subjectNeeded;
        uint hoursRequested;
        uint totalCost;
        bool isTutoringStarted;
    }

    address public owner;
    mapping(address => Tutor) public tutors;
    mapping(address => Student) public students;

    event TutorRegistered(address indexed tutorAddress, string subject, uint hourlyRate, uint hoursAvailable);
    event StudentRegistered(address indexed studentAddress, string subjectNeeded, uint hoursRequested, uint totalCost);
    event TutoringSessionStarted(address indexed studentAddress, address indexed tutorAddress, uint totalCost);
    event TutoringSessionEnded(address indexed studentAddress, address indexed tutorAddress);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier onlyTutor() {
        require(tutors[msg.sender].tutorAddress != address(0), "You are not a registered tutor");
        _;
    }

    modifier onlyStudent() {
        require(students[msg.sender].studentAddress != address(0), "You are not a registered student");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Register a tutor with their subject and hourly rate
    function registerTutor(string memory _subject, uint _hourlyRate, uint _hoursAvailable) public {
        require(tutors[msg.sender].tutorAddress == address(0), "You are already registered as a tutor");
        
        tutors[msg.sender] = Tutor({
            tutorAddress: msg.sender,
            subject: _subject,
            hourlyRate: _hourlyRate,
            hoursAvailable: _hoursAvailable,
            isAvailable: true
        });

        emit TutorRegistered(msg.sender, _subject, _hourlyRate, _hoursAvailable);
    }

    // Register a student with the subject they need tutoring in
    function registerStudent(string memory _subjectNeeded, uint _hoursRequested) public {
        require(students[msg.sender].studentAddress == address(0), "You are already registered as a student");

        uint totalCost = tutors[msg.sender].hourlyRate * _hoursRequested;
        
        students[msg.sender] = Student({
            studentAddress: msg.sender,
            subjectNeeded: _subjectNeeded,
            hoursRequested: _hoursRequested,
            totalCost: totalCost,
            isTutoringStarted: false
        });

        emit StudentRegistered(msg.sender, _subjectNeeded, _hoursRequested, totalCost);
    }

    // Start the tutoring session
    function startTutoringSession(address _student) public onlyTutor {
        require(tutors[msg.sender].isAvailable, "Tutor is not available for tutoring");
        require(students[_student].isTutoringStarted == false, "Student's tutoring session has already started");
        
        // Mark tutoring session as started
        students[_student].isTutoringStarted = true;

        // Transfer the cost to the tutor (simplified logic for demonstration)
        payable(msg.sender).transfer(students[_student].totalCost);

        emit TutoringSessionStarted(_student, msg.sender, students[_student].totalCost);
    }

    // End the tutoring session
    function endTutoringSession(address _student) public onlyTutor {
        require(students[_student].isTutoringStarted == true, "Tutoring session has not started yet");
        
        // Mark tutoring session as ended
        students[_student].isTutoringStarted = false;

        emit TutoringSessionEnded(_student, msg.sender);
    }

    // Function to receive Ether (for simplicity)
    receive() external payable {}

}
