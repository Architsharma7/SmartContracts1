// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TodoList {
    address public owner;

    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not owner");
        _;
    }

    uint public taskId;

    struct Tasks{
        uint taskId;
        string data;
        bool completed;
    }

    Tasks[] public TaskList;

    event Addtask(uint taskId);
    event UpdateTask(uint taskId);
    event MarkCompleted(uint taskId);

    // calldata instead of memory will save gas ,fetching from memory , requires more gas
    function createTask(uint _taskId, string calldata _data) external onlyOwner {
        TaskList.push(Tasks({
            taskId: _taskId,
            data: _data,
            completed: false
        }));
        emit Addtask(_taskId);
    }

    function updateTask(uint _taskId, string calldata _data) external onlyOwner {
        TaskList[_taskId].data = _data;
        emit UpdateTask(_taskId);
    }

    function completed(uint _taskId) external onlyOwner {
        Tasks memory task = TaskList[_taskId];
        task.completed = true;
        emit MarkCompleted(task.taskId);
    }

    function getTasks(uint _taskId) external view returns(string memory, bool){
        Tasks memory task = TaskList[_taskId];
        return(task.data, task.completed);
    }

    function getAllTasks() external view returns(Tasks[] memory){
        return TaskList;
    }
}


//////////// OTHER WAY OF DOING IT USING MAPPINGS /////////////////


contract TodoList2{
    address public owner;

    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not owner");
        _;
    }
    uint public taskNo;

    mapping(uint => string) public Tasks;
    mapping(uint => bool) public completedTask;

    event taskAdded(string task) ;
    event taskCompleted(uint task);

    function addTask(string calldata _task, uint _taskNo) public onlyOwner {
        Tasks[_taskNo] = _task;
        completedTask[_taskNo] = false;
        emit taskAdded(_task);
    }

    function completeTask(uint _taskNo) public onlyOwner {
        completedTask[_taskNo] = true;
        emit taskCompleted(_taskNo);
    }

    function getTask(uint _taskNo) public view onlyOwner returns(string memory, bool ){
        return (Tasks[_taskNo], completedTask[_taskNo]);
    }
}