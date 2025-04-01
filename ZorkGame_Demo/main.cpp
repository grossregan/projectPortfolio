/*Zorkstranauts Game
Regan Gross
Jonathan Kivisto
Kamden T. Ernste
CS1511
Started 11/1/2023 */
#include <iostream>
#include <string>
#include <cstdlib> // For rand() and srand()
#include <ctime>   // For time()



using namespace std;




struct Room {
    string name;
    string description;
    bool hasWeapon;
    bool hasLocker;
    Room* connectedRooms[7]; // Array to hold connected rooms
};

class Monster {
    private:
        int kills=0; //defines number of times player has killed the xenomorph

    public:
        string name;
        int health;
        void setKills(int numKills){
            kills=numKills;
        }

        bool encounterCheck(){
            int alienLoc=rand()%100+1;

            cout<<alienLoc<<endl;

            bool encounter=false;

            if (kills==0 && alienLoc<=20){ //Xenomorph Encounter possibility
                encounter= true;
            }
            if(kills==1 && alienLoc<=15){
                encounter= true;
            }
            if(kills==2 && alienLoc <= 10) {
                encounter= true;
            }
            if(kills==3 && alienLoc <= 5) {
                encounter= true;
            }
            return encounter;
        }
        bool getKills() const{
            return kills;
        };
};

struct Player{
    string name;
    int health;
    bool weapon;
};


// Function prototypes
void handleRoom(Room* currentRoom, bool& weapon, bool& locker);
int alienBattle(Room* currentRoom, bool &weapon);
void room1(Room* currentRoom, bool& weapon, bool& locker);
void room2(Room* currentRoom, bool& weapon, bool& locker);
void room3(Room* currentRoom, bool& weapon, bool& locker);
void room4(Room* currentRoom, bool& weapon, bool& locker);
void room5(Room* currentRoom, bool& weapon, bool& locker);
void room6(Room* currentRoom, bool& weapon, bool& locker);
void room7(Room* currentRoom, bool& weapon, bool& locker);

Player player;

int alienBattle(Room* currentRoom,bool& weapon){
    //creating the xeno
    Monster xeno;
    xeno.name= "Xenomorph";
    xeno.health=50;

    //creating player

    player.name="You";
    player.health=100;

    int fightDecision; //set path for fight

    char attack; //creates input for player

    int runSuccess;//creates ability for player to run away

    int totalKills = xeno.getKills(); //gets current kill count

    while(xeno.encounterCheck()) { //makes alien battle run wih given probability
        if (player.weapon) { //if the player DOES have a weapon
            cout << "You have encountered a xenomorph!! You have 2 options:\n"
                    "1: Attack the xenomorph\n"
                    "2: Run from it\n"
                    "Which do you pick?: ";
            cin >> fightDecision;
            switch (fightDecision) {
                case 1:
                    cout << "You have chosen to attack!\n"
                            "Type ''H'' to shoot at the Xenomorph with your railgun: \n";
                    cin >> attack;
                    while (attack != 'H') {
                        cout << "Please enter a valid input.";
                        cin >> attack;
                    }

                    int alienHit;
                    alienHit = rand() % 2 + 1;//define which path to take

                    if (alienHit == 1) {
                        cout << "Direct hit!!" << endl;
                        xeno.health = 0;
                    } else {
                        cout << "Your shot wounds the xenomorph, but does not kill him!";
                        xeno.health = xeno.health - 15;
                        cout << "The alien's health is now at: " << xeno.health<<endl;
                        cout << "You have sufficiently pissed it off now.\n"
                                "The xenomorph counterattacks. His otherworldly strength knocks you down.";
                        player.health = player.health - 20;
                        cout<<"Your health is now at: "<<player.health<<endl;
                        cout << "Type ''H'' to shoot at the Xenomorph with your railgun: \n";
                        cin >> attack;
                        while (attack != 'H') {
                            cout << "Please enter a valid input.";
                            cin >> attack;
                        }
                        cout << "In your weakened state your aim is not very good...\n"
                                "You manage to make contact still, this blow does the trick! ";
                        xeno.health = 0;
                    }

                    if (xeno.health == 0) {//end fight conditions
                        xeno.setKills(totalKills+1);//move kill counter up 1
                        xeno.health=50;//resets health

                        if (totalKills <= 3) { //xenomorph kill
                            cout<< "You have defeated the Xenomorph! Be cautious though, there may still be more out there...";
                        } else { //last xenomorph code
                            cout << "You have defeated the Xenomorph! Continue to proceed with caution, "
                                    "but there must not be anymore of those things. That'd be crazy!";
                        }
                    }
                    break;
                case 2:
                    cout << "You have chosen to run away...\n"
                            "coward."<<endl;
                    runSuccess = rand() % 10 + 1;
                    if (runSuccess < 5) {
                        cout << "Your attempt to run away has failed. "
                                "The xenomorph caught you and you are now dead. :(";
                        exit(1); //Maybe change later into a loop that will start the game over
                    } else {
                        cout << "Your attempt to run has succeeded! You will live to see another day.";
                        break;
                    }

            }
        }else { //else case is if player has no weapon
            cout << "You have encountered a xenomorph!! You have 2 options:\n"
                    "1: Approach the xenomorph\n"
                    "2: Run from it\n"
                    "Which do you pick?: ";
            cin >> fightDecision;
            switch (fightDecision) {
                case 1:
                    cout << "The Xenomorph attacked you. You are now dead :(";
                    return -1;
                case 2:
                    cout << "You have chosen to run away...\n"
                            "coward.";
                    runSuccess = rand() % 10 + 1;
                    if (runSuccess < 5) {
                        cout << "Game Over!!\n"
                                "Your attempt to run away has failed. The xenomorph caught you and you are now dead. :(";
                        exit(1);
                    } else {
                        cout << "Your attempt to run has succeeded! You will live to see another day.";
                        break;
                    }
            }

        }
    }
    return xeno.getKills(); //returns updated kill count
}


// Function to handle the room functionalities
void handleRoom(Room* currentRoom, bool& weapon, bool& locker) {
    cout << "You are in " << currentRoom->name << endl;
    cout << currentRoom->description << endl;
    alienBattle(currentRoom,weapon); //run battle check



    // Check if the room has a weapon
    if (currentRoom->hasLocker) {
        cout << "Would you like to open the lockers? (y/n)" << endl;
        char answer1;
        cin >> answer1;
        if (answer1 == 'y' || answer1 == 'Y') {
            currentRoom->hasLocker = true;
            cout << "You opened the lockers" << endl;
            locker = false;
            if (!currentRoom->hasWeapon){
                cout << "You search the lockers again and found nothing of use" << endl;
            }
            if (currentRoom->hasWeapon) {
                cout << "There is a railgun here. Do you want to pick it up? (y/n)" << endl;
                char answer2;
                cin >> answer2;
                if (answer2 == 'y' || answer2 == 'Y') {
                    currentRoom->hasWeapon = false;
                    cout << "You picked up the weapon!" << endl;
                    player.weapon = true;
                }
            }
        }
    }




    // Check and display available connected rooms
    int size= sizeof(currentRoom->connectedRooms)/sizeof(currentRoom->connectedRooms[0]);




    cout << "Available rooms: ";
    int availableRooms = 0;
    for (int i = 0; i < size; ++i) {
        if (currentRoom->connectedRooms[i] != nullptr) {
            cout << currentRoom->connectedRooms[i]->name;
            availableRooms++;
        }if (i<size-1){
            cout<<", ";
        }




    }
    cout << endl;




    // Check if there are available rooms to move to
    if (availableRooms == 0) {
        cout << "There are no available rooms to move to. Game over!" << endl;
        exit(0); // Terminate the game if there are no available rooms
    }




    // Ask the player which room they want to go to next
    string roomChoice;
    cout << "Which room do you want to go to next? ";
    cin >> roomChoice;




    // Validate the player's choice and move to the selected room
    bool isValidChoice = false;
    for (int i = 0; i < size; ++i) {
        if (currentRoom->connectedRooms[i] != nullptr && roomChoice == currentRoom->connectedRooms[i]->name) {
            currentRoom = currentRoom->connectedRooms[i];
            isValidChoice = true;
            break;
        }
    }




    // Handle invalid room choice and recursively call handleRoom for the chosen room
    if (!isValidChoice) {
        cout << "Invalid room choice. Please choose a valid room." << endl;
    } else {
        handleRoom(currentRoom, weapon, locker); // Recursively handle the chosen room
    }
}








// Function for Room 1
void room1(Room* currentRoom, bool& weapon, bool& locker) {
    cout << "You are in " << currentRoom->name << endl;
    cout << currentRoom->description << endl;
    if (currentRoom->hasLocker) {
        cout << "Would you like to open the lockers? (y/n)" << endl;
        char answer1;
        cin >> answer1;
        if (answer1 == 'y' || answer1 == 'Y') {
            currentRoom->hasLocker = true;
            cout << "You opened the lockers" << endl;
            locker = true;
            if (currentRoom->hasWeapon) {
                cout << "There is a railgun here. Do you want to pick it up? (y/n)" << endl;
                char answer2;
                cin >> answer2;
                if (answer2 == 'y' || answer2 == 'Y') {
                    currentRoom->hasWeapon = false;
                    cout << "You picked up the weapon!" << endl;
                    weapon = false;
                }
            }
        }
    }
}




// Function for Room 2
void room2(Room* currentRoom, bool& weapon) {
    cout << "You are in " << currentRoom->name << endl;
    cout << currentRoom->description << endl;




    if (currentRoom->hasWeapon) {
        cout << "There is a weapon in this room. Do you want to pick it up? (y/n)" << endl;
        char answer;
        cin >> answer;
        if (answer == 'y' || answer == 'Y') {
            currentRoom->hasWeapon = false;
            cout << "You picked up the weapon!" << endl;
            weapon = false;
        }
    }
}




// Function for Room 3
void room3(Room* currentRoom, bool& weapon) {
    cout << "You are in " << currentRoom->name << endl;
    cout << currentRoom->description << endl;
    if (currentRoom->hasWeapon) {
        cout << "There is a weapon in this room. Do you want to pick it up? (y/n)" << endl;
        char answer;
        cin >> answer;
        if (answer == 'y' || answer == 'Y') {
            currentRoom->hasWeapon = false;
            cout << "You picked up the weapon!" << endl;
            weapon = false;
        }
    }
}




// Function for Room 4
void room4(Room* currentRoom, bool& weapon) {
    cout << "You are in " << currentRoom->name << endl;
    cout << currentRoom->description << endl;


    if (currentRoom->hasWeapon) {
        cout << "There is a weapon in this room. Do you want to pick it up? (y/n)" << endl;
        char answer;
        cin >> answer;
        if (answer == 'y' || answer == 'Y') {
            currentRoom->hasWeapon = false;
            cout << "You picked up the weapon!" << endl;
            weapon = false;
        }
    }
}




// Function for Room 5
void room5(Room* currentRoom, bool& weapon) {
    cout << "You are in " << currentRoom->name << endl;
    cout << currentRoom->description << endl;

    if (currentRoom->hasWeapon) {
        cout << "There is a weapon in this room. Do you want to pick it up? (y/n)" << endl;
        char answer;
        cin >> answer;
        if (answer == 'y' || answer == 'Y') {
            currentRoom->hasWeapon = false;
            cout << "You picked up the weapon!" << endl;
            weapon = false;
        }
    }
}
void room6(Room* currentRoom, bool& weapon) {
    cout << "You are in " << currentRoom->name << endl;
    cout << currentRoom->description << endl;




    if (currentRoom->hasWeapon) {
        cout << "There is a weapon in this room. Do you want to pick it up? (y/n)" << endl;
        char answer;
        cin >> answer;
        if (answer == 'y' || answer == 'Y') {
            currentRoom->hasWeapon = false;
            cout << "You picked up the weapon!" << endl;
            weapon = false;
        }
    }
}
void room7(Room* currentRoom, bool& weapon) {
    cout << "You are in " << currentRoom->name << endl;
    cout << currentRoom->description << endl;




    if (currentRoom->hasWeapon) {
        cout << "There is a weapon in this room. Do you want to pick it up? (y/n)" << endl;
        char answer;
        cin >> answer;
        if (answer == 'y' || answer == 'Y') {
            currentRoom->hasWeapon = false;
            cout << "You picked up the weapon!" << endl;
            weapon = false;
        }
    }
}




int main() {
    // Seed the random number generator with the current time
    srand((unsigned) time(NULL));




    // Create seven rooms
    Room room1 = {"Base","You are standing inside NASA’s first ground base on Mars. \n"
                         "The room is empty aside from a 4 lockers in the conner and the lights are flickering. \n"
                         "Not much can be discerned from your current vantage point.", true, true, {nullptr}};
    Room room2 = {"East", "You are standing on dusty ground."
                                "To the west of you is a large building, with glass all around it. \n"
                                "Further behind that is a shiny metal building. \n"
                                "To the south and north, there is nothing.\n", false, false, {nullptr}};
    Room room3 = {"North", "You are standing on the top of a small hill. \n"
                                 "To the south you see a large building, to the west and east you see nothing. \n"
                                 "In the distance you see a cliff with a small cave entrance.", false,false, {nullptr}};
    Room room4 = {"South", "To the north, you can see the base in the distance.\n"
                                 " To the west, there appears to be an old, broken down rover. \n"
                                 "To the southwest, a communications tower is in view.", false,false, {nullptr}};
    Room room5 = {"West", "To the south there is an old broken down rover.\n"
                                "To the east, you see your a large building, your base, but there is no evident way in.\n"
                                " You seem to be a bit closer to the cliffs now;\n", false,false, {nullptr}};
    Room room6={"Greenhouse","You stand within the verdant embrace of a Martian greenhouse.\n"
                             "The dome above revealing the ruddy expanse of the alien desert beyond;\n"
                             "on the far side of the room you see an old rover and scraps of wiring.\n"
                             "By the old rover you see a large cabinet.", false, false,{nullptr}};
    Room room7={"commTower", "You are now at what appears to be an abandoned communications tower. \n"
                           "In front of you are a series of buttons. \n"
                           "There is a purple, red, green, black. and a white button.", false,false, {nullptr}};





    // Connect the rooms according to the specified connections
    room1.connectedRooms[0] = &room6;
    room1.connectedRooms[1] = &room2;
    room1.connectedRooms[2] = &room5;
    room1.connectedRooms[3] = &room4;// Connecting room1 to room6,room2,room5,room4

    room2.connectedRooms[0] = &room1;// Connecting room2 to room5

    room3.connectedRooms[0] = &room6;// Connecting room3 to room1

    room4.connectedRooms[0] = &room1;// Connecting room4 to room5
    room4.connectedRooms[1] = &room7;

    room5.connectedRooms[0] = &room1; // Room 1 can only be accessed from Room 5
    room5.connectedRooms[1] = &room7;

    room6.connectedRooms[0] = &room3;
    room6.connectedRooms[1] = &room1;

    room7.connectedRooms[0] = &room4;
    room7.connectedRooms[1] = &room5;

    // Create the 1 weapon
    bool weapon = true;

    //create locker
    bool locker;


    // Start the game in Room 1
    Room* currentRoom = &room1;


    // Game loop
    while (true) {
        handleRoom(currentRoom, weapon, locker);
        alienBattle(currentRoom,weapon);
        // Ask the player which room they want to go to next
        int size = sizeof(currentRoom->connectedRooms) / sizeof(currentRoom->connectedRooms[0]);
        cout << "Which room do you want to go to next? ";
        cout << "(Available rooms: ";
        for (int i = 0; i < size; ++i) {
            if (currentRoom->connectedRooms[i] != nullptr) {
                cout << currentRoom->connectedRooms[i]->name << " ";
            }


        }
        cout << ")" << endl;


        string roomChoice;
        cin >> roomChoice;


        bool isValidChoice = false;
        for (int i = 0; i < 7; ++i) {
            if (currentRoom->connectedRooms[i] != nullptr &&
                roomChoice == currentRoom->connectedRooms[i]->name) {
                currentRoom = currentRoom->connectedRooms[i];
                isValidChoice = true;
                break;
            }
        }
        if (!isValidChoice) {
            cout << "Invalid room choice. Please choose a valid room." << endl;
        }
    }
    return 0;
}
