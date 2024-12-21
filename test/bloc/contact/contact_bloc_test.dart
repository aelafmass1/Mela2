import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:transaction_mobile_app/bloc/contact/contact_bloc.dart';
import 'package:transaction_mobile_app/core/exceptions/server_exception.dart';

import '../../helper/helper.mocks.dart';

void main() {
  late ContactBloc contactBloc;
  late MockContactRepository mockRepository;

  // Mock data
  final mockContacts = [
    Contact(
      id: '1',
      displayName: 'John Doe',
      phones: [Phone('1234567890')],
    ),
    Contact(
      id: '2',
      displayName: 'Jane Smith',
      phones: [Phone('0987654321')],
    ),
  ];

  final mockRemoteResponse = [
    {"contactId": "1"},
    {"contactId": "2"},
  ];

  final mockErrorResponse = [
    {"error": "Something went wrong"}
  ];

  final mockTagSearchResponse = [
    {
      "id": 0,
      "firstName": "Tagged",
      "lastName": "User",
      "enabled": true,
      "createdDate": "2024-12-15T13:51:44.052Z",
      "userTag": "user123"
    }
  ];

  setUp(() {
    mockRepository = MockContactRepository();
    contactBloc = ContactBloc(repository: mockRepository);
  });

  tearDown(() {
    contactBloc.close();
  });

  group('ContactBloc', () {
    blocTest<ContactBloc, ContactState>(
      'emits [ContactLoading, ContactFilterSuccess] when FetchContacts is successful',
      build: () {
        // Mock successful responses
        when(mockRepository.fetchLocalContacts())
            .thenAnswer((_) async => Future.value(mockContacts));
        when(mockRepository.checkMyContacts(
          contacts: mockContacts,
        )).thenAnswer((_) async => mockRemoteResponse);

        return contactBloc;
      },
      act: (bloc) => bloc.add(FetchContacts()),
      expect: () => [
        const ContactLoading(),
        isA<ContactFilterSuccess>().having(
          (state) => state.remoteContacts,
          'remoteContacts',
          ['1', '2'],
        ),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'emits [ContactLoading, ContactFail] when FetchContacts fails',
      build: () {
        when(mockRepository.fetchLocalContacts())
            .thenAnswer((_) async => mockContacts);
        when(mockRepository.checkMyContacts(
          contacts: mockContacts,
        )).thenAnswer((_) async => mockErrorResponse);

        return contactBloc;
      },
      act: (bloc) => bloc.add(FetchContacts()),
      expect: () => [
        const ContactLoading(),
        isA<ContactFail>().having(
          (state) => state.message,
          'message',
          'Something went wrong',
        ),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'emits [ContactFilterLoading, ContactFilterSuccess] when SearchContacts with normal query',
      setUp: () {
        // Set initial state with mock data
        contactBloc.emit(ContactFilterSuccess(
          filteredContacts: const [],
          localContacs: mockContacts,
          remoteContacts: const {},
        ));
      },
      build: () => contactBloc,
      act: (bloc) => bloc.add(SearchContacts(query: 'john')),
      expect: () => [
        isA<ContactFilterLoading>(),
        isA<ContactFilterSuccess>().having(
          (state) => state.filteredContacts.length,
          'filteredContacts length',
          1,
        ),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'emits [ContactFilterLoading, ContactFilterSuccess] when SearchContacts with tag query',
      setUp: () {
        contactBloc.emit(ContactFilterSuccess(
          filteredContacts: const [],
          localContacs: mockContacts,
          remoteContacts: const {},
        ));

        when(mockRepository.searchContactsByTag(
          query: anyNamed('query'),
        )).thenAnswer((_) async => mockTagSearchResponse);
      },
      build: () => contactBloc,
      act: (bloc) => bloc.add(SearchContacts(query: '@user123')),
      expect: () => [
        isA<ContactFilterLoading>(),
        isA<ContactFilterSuccess>().having(
          (state) => state.filteredContacts.length,
          'filteredContacts length',
          1,
        ),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'emits [ContactFilterLoading, ContactFilterSuccess] with empty results when tag search fails',
      setUp: () {
        contactBloc.emit(ContactFilterSuccess(
          filteredContacts: const [],
          localContacs: mockContacts,
          remoteContacts: const {},
        ));

        when(mockRepository.searchContactsByTag(
          query: anyNamed('query'),
        )).thenAnswer((_) async => [
              {'error': 'Tag not found'}
            ]);
      },
      build: () => contactBloc,
      act: (bloc) => bloc.add(SearchContacts(query: '@nonexistent')),
      expect: () => [
        isA<ContactFilterLoading>(),
        isA<ContactFilterSuccess>().having(
          (state) => state.filteredContacts.length,
          'filteredContacts length',
          0,
        ),
      ],
    );

    test('emites ContactFilterFailed when repository throws Exception',
        () async {
      when(mockRepository.checkMyContacts(contacts: mockContacts))
          .thenThrow(ServerException('Oops! Something went wrong.', 400));

      contactBloc.add(FetchContacts());

      await expectLater(
        contactBloc.stream,
        emitsInOrder([
          const ContactLoading(),
          isA<ContactFail>(),
        ]),
      );
    });
  });
}
